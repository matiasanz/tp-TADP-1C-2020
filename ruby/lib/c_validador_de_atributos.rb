require 'b_atributos_persistibles'

module ORM

    module ValidadorDeAtributos
        def self.extended(modulo)
            @validadores ||= []
            @validadores << modulo

            modulo.define_method(:simbolo) do
                self.class.simbolo
            end
        end

        def self.as_validadores(tipo, args)
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
            raise CampoIncorrectoException.new(args[simbolo], Proc, simbolo) unless args[simbolo].is_a?Boolean
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
            raise CampoIncorrectoException.new(@validacion, Proc, simbolo) unless @validacion.is_a?Proc
        end

        def validar(atributo, dato)
            puts dato.instance_eval(&@validacion).inspect
            raise ValidateException.new(atributo, dato) unless (dato.instance_eval(&@validacion))
        end
    end
end