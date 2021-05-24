
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
        super("#{actual.inspect} no es aceptado para el campo #{tipoEsperado.to_s} <<#{campo}>>")
    end
end

class ValidacionNoAdmitidaException < StandardError
    def initialize(clase, validacion)
        super("La validacion #{validacion.inspect} no se admite para la clase #{clase.to_s}")
    end
end

class ValidateException < StandardError
    def initialize(dato)
        super("El elemento #{dato.inspect} no cumple con la condicion establecida como validate")
    end
end

class RangoExcedidoException < StandardError
    def initialize(dato, from, to)
        super("El campo #{dato.to_s} no se encuentra dentro del rango [#{from.to_s||"-inf"}; #{to.to_s||"+inf"}]")
    end
end

class BlankException < StandardError
    def initialize(dato)
        super("Un campo declarado no_blank es #{dato.inspect}")
    end
end

class HasArgsIncorrectosException < StandardError
    def initialize(parametrosSobrantes)
        super("Se ingresaron parametros incorrectos: #{parametrosSobrantes.to_s}")
    end
end

class ValidadorNilException < StandardError
    def initialize
        super("Validador no seteado exception")
    end
end


