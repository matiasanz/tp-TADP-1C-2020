class Symbol
    def to_param
        "@#{self.to_s}".to_sym
    end

    def param?
        self.to_s.start_with? '@'
    end
end

module Boolean
end

class TrueClass
    include Boolean
end

class FalseClass
    include Boolean
end

class Atributo
    attr_accessor :tipo

    def initialize(clase)
        raise "El nombre #{clase.to_s} no se reconoce como clase o modulo" unless clase.is_a?(Module)
        @clase=clase
    end

    def agregar_a_fila(nombre, valor, fila)
        validar_tipo(valor)
        fila[nombre] = valor
    end

    def recuperar_de_fila(nombre, fila)
        fila[nombre]
    end

    def validar_tipo(objeto)
        raise "El objeto #{objeto.to_s} no pertenece a la clase #{@clase.to_s.inspect}" unless objeto.is_a? @clase
    end
end

class AtributoCompuesto < Atributo
    def initialize(clase)
        super(clase)
    end

    def agregar_a_fila(nombre, objeto, fila)
        validar_tipo(objeto)
        fila[nombre] = valor_persistible_de(objeto)
        fila[nombre.to_param] = objeto.class.to_s
    end

    def recuperar_de_fila(nombre, fila)
        id = super.recuperar_de_fila(nombre, fila)
        clase = clase_actual(nombre, fila)
        clase.find_by_id(id).first
    end

    def valor_persistible_de(objeto)
        objeto.save!
        objeto.id
    end

    private
    def clase_actual(campo, fila)
        super.recuperar_de_fila(campo.to_param, fila, true)
        fila[campo.to_param].constantize
    end
end