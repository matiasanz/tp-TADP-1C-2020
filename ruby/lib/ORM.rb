require 'adapter'

class Class

    attr_reader :atributos_persistibles

    def has_one(tipo, named)

        if @atributos_persistibles.nil?
            @atributos_persistibles = {}
        end

        @atributos_persistibles[named] = tipo
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