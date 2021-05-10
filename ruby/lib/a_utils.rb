class Symbol
    def to_param
        "@#{self.to_s}".to_sym
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
        raise "La clase #{clase.to_s} no existe" unless clase.is_a?(Class)
        @tipo=clase
    end

    def validar_tipo(objeto)
        raise "El objeto #{objeto.to_s} no es del tipo especificado" unless objeto.is_a? @tipo
    end
end

class AtributoPrimitivo < Atributo
    def initialize(tipo)
        super(tipo)
    end

    def valor_persistible_de(objeto)
        validar_tipo(objeto)
        objeto
    end

    def get_real_value(objeto)
        objeto
    end
end

class AtributoCompuesto < Atributo
    def initialize(tipo)
        super(tipo)
    end

    def valor_persistible_de(objeto)
        validar_tipo(objeto)
        @claseActual = objeto.class
        objeto.save!
        objeto.id
    end

    def get_real_value(objeto)
        @claseActual.find_by_id(objeto).first
    end
end