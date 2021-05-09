require 'adapter'

class Class

    def has_one(tipo, named)
        if @atributos_persistibles.nil?
            @atributos_persistibles = {}
            definir_find_by(:id)
        end
        @atributos_persistibles[named] = tipo

        definir_find_by(named)
    end

    def atributos_persistibles
        persistibles_propios.merge(persistibles_heredados)
    end

    def all_instances
        tabla(self).all_instances
    end

    def tabla(clase)
        DataBase.new.get_tabla(clase)
    end

    private
    def persistibles_propios
        @atributos_persistibles.nil?()?
            {} : @atributos_persistibles
    end

    def persistibles_heredados
        (superclass != BasicObject and superclass.respond_to?(:atributos_persistibles))?
            superclass.atributos_persistibles : {}
    end

    def definir_find_by(named)
        define_singleton_method("find_by_#{named.to_s}".to_sym) do
        |valor|
            tabla(self).get_by(named, valor)
        end
    end
end

class Object
    attr_accessor :id

    def save!
        DataBase.new.get_tabla(self.class).persist(self)
    end

    def atributos_persistibles()
        self.class.atributos_persistibles
            .map{|nombre, tipo| get_campo(nombre, tipo)}
    end

    private
    def get_campo(nombre, tipo)
        valor = instance_variable_get(sim_to_atribute(nombre))
        {nombre: nombre, tipo: tipo, valor: valor}
    end

    def sim_to_atribute(nombre)
        "@#{nombre}".to_sym
    end
end