require 'b_atributos_persistibles'

module ORM

    module ValidadorDeAtributos
        def self.extended(modulo)
            @validadores ||= []
            @validadores << modulo
        end

        def self.as_validadores(tipo, args)
            #probar args.to_a.filter_map
            actuales = []
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
        extend ValidadorDeAtributos

        def self.aplica?(args)
            true
        end

        def initialize(tipo, args)
            #no hace nada
        end

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
            simbolo = self.class.simbolo
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
            simbolo = self.class.simbolo
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
            simbolo = self.class.simbolo
            @validacion = args[simbolo]
            raise CampoIncorrectoException.new(@validacion, [Proc, Lambda], simbolo) unless @validacion.is_a?Proc or @validacion.lambda?
        end

        def validar(atributo, dato)
            puts dato.instance_eval(&@validacion).inspect
            raise ValidateException.new(atributo, dato) unless (dato.instance_eval(&@validacion))
        end
    end
end