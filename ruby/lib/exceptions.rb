module ORM
    class ObjetoNoPersistidoException < StandardError
        def initialize(objeto)
            super("el objeto #{objeto.to_s} no se encuentra persistido")
        end
    end

    class ClaseDesconocidaException < StandardError
        def initialize(clase)
            super("El nombre #{clase.to_s.inspect} no se reconoce como clase o modulo")
        end
    end

    class ClaseNoPersistibleException < StandardError
        def initialize(clase)
            super("La clase #{clase.to_s} no se ha declarado persistible")
        end
    end

    class TipoErroneoException < StandardError
        def initialize(objeto, clase)
            super("El objeto #{objeto.to_s} no pertenece a la clase especificada #{clase.to_s.inspect}")
        end
    end

    class PropertyNotFoundException < StandardError
        def initialize(property, clase)
            super("#{property.to_s} no es una property de la clase #{clase.to_s}")
        end
    end

    class MetodoAbstractoException < StandardError
        def initialize
            super("Se intento ejecutar un metodo que pretende ser abstracto, no sobrecargado")
        end
    end

    class CampoIncorrectoException < StandardError
        def initialize(actual, tipoEsperado, campo)
            super("#{actual.inspect} no es aceptado para el campo #{tipoEsperado.to_s} <<#{campo.to_s}>>")
        end
    end

    class ValidacionNoAdmitidaException < StandardError
        def initialize(clase, validacion)
            super("La validacion #{validacion.inspect} no se admite para la clase #{clase.to_s}")
        end
    end

    class ValidacionInexistenteException < StandardError
        def initialize(validacion)
            super("La validacion #{validacion.inspect} no se encuentra entre las definidas")
        end
    end

    class AtributoPersistibleException < StandardError
        def initialize(atributo, dato, condiciones)
            super("El elemento #{dato.inspect} no cumple con las condiciones establecidas para el campo #{atributo.nombre.to_s} de clase #{atributo.clase.to_s}:\n"+ condiciones.map{|c| "-#{c.nombre}: #{c.mensaje}"}.join('\n'))
        end
    end

    class HasArgsIncorrectosException < StandardError
        def initialize(parametrosSobrantes)
            super("Se ingresaron parametros incorrectos: #{parametrosSobrantes.to_s}")
        end
    end
end

