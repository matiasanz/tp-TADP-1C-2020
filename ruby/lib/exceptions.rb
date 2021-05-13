
class ObjetoNoPersistidoException < StandardError
    def initialize(objeto)
        super("el objeto #{objeto.to_s} no se encuentra persistido")
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