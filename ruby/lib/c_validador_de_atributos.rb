require 'b_atributos_persistibles'

module ORM

    class Validador
        def initialize(validadores)
            @validadores = validadores
        end

        def validar(atributo, objeto)
            erroresDetectados = @validadores.select{|v| not v.call(objeto)}

            if not erroresDetectados.empty?
                raise AtributoPersistibleException.new(atributo, objeto, erroresDetectados)
            end
        end
    end

    module ValidacionesFactory

        def self.from_args(tipo, args)
            args.filter_map {|k,v| self.send(k, v) if v and k!=:named and k!=:default}
            validaciones = [tipo(tipo)]
            validaciones << no_blank if args[:no_blank]
            validaciones << to(args[:to]) if args[:to]
            validaciones << from(args[:from]) if args[:from]
            validaciones << validate(args[:validate]) if args[:validate]
            Validador.new(validaciones)
        end

        def self.tipo(tipo)
            validador("tipo", "no es un #{tipo.to_s}") {|o| o.nil? or o.is_a? tipo}
        end

        def self.to(maximo)
            raise CampoIncorrectoException.new(maximo, Numeric, "to") unless maximo.is_a?Numeric
            validador("to", "menor o igual a #{maximo.to_s}") {|o| o.nil? or o <= maximo}
        end

        def self.from(minimo)
            raise CampoIncorrectoException.new(minimo, Numeric, "from") unless minimo.is_a?Numeric
            validador("from", "mayor o igual a #{minimo.to_s}") {|o| o.nil? or o >= minimo}
        end

        def self.validate(accion)
            raise CampoIncorrectoException.new(accion, [Proc, Lambda], simbolo) unless accion.is_a?Proc or accion.lambda?
            validador("validate", "") {|o| o.instance_eval(&accion)}
        end

        def self.no_blank(arg = true)
            raise CampoIncorrectoException.new(arg, Boolean, "no_blank") unless arg.is_a? Boolean
            validador("no_blank", "") {|o| not (o.nil?) } unless not arg
        end

        def self.validador(nombre, mensaje, &accion)
            val = proc &accion
            val.define_singleton_method(:nombre) {nombre}
            val.define_singleton_method(:mensaje) {mensaje}
            val
        end
    end

    #------------------------------

    module ValidadorDeAtributos
        def self.extended(modulo)
            @validadores ||= []
            @validadores << modulo

            modulo.define_method(:simbolo) do
                self.class.simbolo
            end
        end

        def self.as_validadores(tipo, args)
            #probar args.to_a.filter_map
            actuales = [ValidadorTipo.new]
            @validadores.each do |validador|
                actuales << validador.new(tipo, args) if validador.aplica?(args)
            end
            actuales
        end

        def aplica?(args)
            args[simbolo]
        end
   end

    class ValidadorTipo
        def validar(atributo, dato)
            clase = atributo.clase
            raise TipoErroneoException.new(dato, clase) unless dato.is_a? clase or dato.nil?
        end
    end

    class ValidadorNoBlank
        extend ValidadorDeAtributos

        def self.simbolo
            :no_blank
        end

        def initialize(tipo, args)
            #no hacer nada
        end

        def validar(atributo, dato)
            raise BlankException.new(atributo, dato) if dato.nil?
        end
    end

    class ValidadorFrom
        extend ValidadorDeAtributos

        def self.simbolo
            :from
        end

        def initialize(tipo, args)
            @from = args[simbolo]
            raise ValidacionNoAdmitidaException.new(tipo, simbolo) unless tipo <= Numeric
            raise CampoIncorrectoException.new(@from, Numeric, "from") unless @from.is_a?Numeric
        end

        def validar(atributo, dato)
            raise FromException.new(atributo, dato, @from) unless dato>=@from
        end
    end

    class ValidadorTo
        extend ValidadorDeAtributos

        def self.simbolo
            :to
        end

        def initialize(tipo, args)
            @to= args[simbolo]
            raise ValidacionNoAdmitidaException.new(tipo, simbolo) unless tipo <= Numeric
            raise CampoIncorrectoException.new(@to, Numeric, simbolo) unless @to.is_a?Numeric
        end

        def validar(atributo, dato)
            raise ToException.new(atributo, dato, @to) unless dato<=@to
        end
    end

    class ValidadorValidate
        extend ValidadorDeAtributos

        def self.simbolo
            :validate
        end

        def initialize(_, args)
            @validacion = args[simbolo]
            raise CampoIncorrectoException.new(@validacion, [Proc, Lambda], simbolo) unless @validacion.is_a?Proc or @validacion.lambda?
        end

        def validar(atributo, dato)
            raise ValidateException.new(atributo, dato) unless (dato.instance_eval(&@validacion))
        end
    end
end