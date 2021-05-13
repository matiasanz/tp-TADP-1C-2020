require_relative 'a_utils'

#*********** Dudoso **************

module AtributoHelper
    def self.clase_primitiva?(clase)
        [String, Boolean, Numeric].include?(clase)
    end

    def self.as_atribute(nombre, clase)
        clase_primitiva?(clase)? AtributoSimple.new(nombre, clase) : AtributoCompuesto.new(nombre, clase)
    end
end

#*********** Atributos Persistibles **************


class AtributoPersistible
    def initialize(nombre, clase)
        raise ClaseDesconocidaException.new(clase) unless clase.is_a?(Module)
        @nombre=nombre
        @clase=clase
    end

    def validar_tipo(objeto)
        raise TipoErroneoException.new(objeto, @clase) unless objeto.is_a? @clase or objeto.nil?
    end
end

class AtributoSimple < AtributoPersistible
    def agregar_a_entrada(valor, entrada)
        validar_tipo(valor)
        entrada[@nombre] = valor
    end

    def recuperar_de_fila(fila)
        fila[@nombre]
    end
end

class AtributoCompuesto < AtributoPersistible
    def agregar_a_entrada(objeto, fila)
        validar_tipo(objeto)
        fila[@nombre] = valor_persistible_de(objeto) unless objeto.nil?
        fila[@nombre.to_param] = objeto.class.to_s
    end

    def recuperar_de_fila(fila)
        clase = fila[@nombre.to_param].to_class

        return nil unless clase.respond_to? :find_by_id
        return clase.find_by_id(fila[@nombre]).first
    end

    private
    def valor_persistible_de(objeto)
        objeto.save!
        objeto.id
    end
end
