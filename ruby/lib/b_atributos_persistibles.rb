require_relative 'a_utils'

#*********** Dudoso **************

module AtributoHelper
    def self.clase_primitiva?(clase)
        [String, Boolean, Numeric].include?(clase)
    end

    def self.as_atribute(nombre, clase)
        # TODO esta muy bueno que usaran este selector para construir el
        # strategy de tipos de atributos, solo tengan en cuenta que si
        # no es atributo simple no necesariamente es atributo "persistible"
        # (van a tener que validar que el tipo del atributo esté "configurado" para
        # ser un tipo persistible para su framework)
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
        # TODO no es necesario persistir el nombre de la clase contra el storage (no lo hagan),
        # deberían poder recuperar la clase en función de la estructura actual del source
        # (si bien es cierto que NO podrían recuperar objetos persistidos que tengan otra
        # estructura diferente a la actual, pero de cualquier forma rompería la deserialización)
        fila[@nombre.to_param] = objeto.class.to_s
    end

    def recuperar_de_fila(fila)
        # TODO aca para evitar ir a buscar el nombre de la clase con el "to_param"
        # usen la clase que ya tienen como variable de instancia (el @clase).
        # Con eso pueden matar el "to_class", "to_param" y "param?"
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
