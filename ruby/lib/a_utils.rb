#************ Utilidades ***********************

class Symbol
    def to_param
        "@#{self.to_s}".to_sym
    end

    def param?
        self.to_s.start_with? '@'
    end
end

class String
    def to_class
        Object.const_get(self)
    end
end

# **************** Booleanos *****************

module Boolean
end

class TrueClass
    include Boolean
end

class FalseClass
    include Boolean
end

#****************** Atributos Persistibles ****************

module AtributoHelper
        def self.clase_primitiva?(clase)
            [String, Boolean, Numeric].include?(clase)
        end

        def self.as_atribute(clase)
            clase_primitiva?(clase)? Atributo.new(clase) : AtributoCompuesto.new(clase)
        end
end

class Atributo
    attr_accessor :tipo

    def initialize(clase)
        raise "El nombre #{clase.to_s} no se reconoce como clase o modulo" unless clase.is_a?(Module)
        @clase=clase
    end

    def agregar_a_entrada(nombre, valor, entrada)
        validar_tipo(valor)
        entrada[nombre] = valor
    end

    def validar_tipo(objeto)
        raise "El objeto #{objeto.to_s} no pertenece a la clase #{@clase.to_s.inspect}" unless objeto.is_a? @clase
    end
end

class AtributoCompuesto < Atributo
    def initialize(clase)
        super(clase)
    end

    def agregar_a_entrada(nombre, objeto, fila)
        validar_tipo(objeto)
        fila[nombre] = valor_persistible_de(objeto)
        fila[nombre.to_param] = objeto.class.to_s
    end

    def valor_persistible_de(objeto)
        objeto.save!
        objeto.id
    end
end