require 'c_adapter'

module ClasePersistible

    #Enunciado
    def has_one(tipo, named:, default: nil, no_blank: false, from: nil, to: nil)
        attr_accessor named
        @atributos_persistibles||={}

        @atributos_persistibles[named] = AtributoHelper.as_atribute(named, tipo)
        definir_find_by_(named, tipo)
    end

    #Enunciado
    def all_instances
        tabla.get_all
    end

    def tabla
        if @tabla.nil?
            @tabla = Tabla.new(self)
        end

        @tabla
    end

    def atributos_persistibles
        persistibles_propios.merge(persistibles_heredados)
    end

    private
    def persistibles_propios
        @atributos_persistibles || {}
    end

    def persistibles_heredados
        (superclass == BasicObject)? {} : superclass.atributos_persistibles
    end

    def definir_find_by_(named, clase)
        get_real_value = AtributoHelper.clase_primitiva?(clase)?
                             lambda{|valor| valor} : lambda{|objeto| objeto.id}

        define_singleton_method("find_by_#{named.to_s}".to_sym) do
        |valor|
            tabla.find_by(named, get_real_value.call(valor))
        end
    end
end

class Object
    extend ClasePersistible

    has_one String, named: :id

    #Enunciado
    def save!
        tabla.persist(self)
    end

    #Enunciado
    def forget!
        tabla.remove(self)
        self.id= nil
    end

    #Enunciado
    def refresh!
        tabla.recuperar_de_db(self)

        self
    end

    def atributos_persistibles
        self.class.atributos_persistibles
            .map do |nombre, atributo|
                [atributo, self.send(nombre)]
            end
    end

    private
    def tabla
        self.class.tabla
    end
end