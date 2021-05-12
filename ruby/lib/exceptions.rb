
class ObjetoNoPersistidoException < StandardError
    def initialize(objeto)
        super("el id del objeto #{objeto.to_s} no se corresponde con ninguno en la base de datos")
    end
end

class ClaseDesconocidaException < StandardError
    def initialize(clase)
        super("El nombre #{clase.to_s} no se reconoce como clase o modulo")
    end
end

class TipoErroneoException < StandardError
    def initialize(objeto, clase)
        super("El objeto #{objeto.to_s} no pertenece a la clase especificada #{clase.to_s.inspect}")
    end
end