require 'c_adapter'

module ClasePersistible

    def inherited(modulo)
        @subclases||=[]
        @subclases << modulo
    end

    #Enunciado
    def has_one(tipo, named:, default: nil, no_blank: false, from: nil, to: nil)
        attr_accessor named
        @atributos_persistibles||={}
        @atributos_persistibles[named] = AtributoHelper.as_atribute(named, tipo)
    end

    #Enunciado
    def all_instances
        tabla.get_all + subclasses.flat_map{|s| s.all_instances}
    end

    #Enunciado
    def atributos_persistibles
        persistibles_heredados.merge(@atributos_persistibles || {})
    end

    #Mover a method missing y hacer que vaya por aca en caso de atributo persistible
    def find_by_id(id)
        tabla.find_by(:id, id) + subclasses.flat_map{|c|c.find_by_id(id)}
        # Lo defino por separado, para evitar tener que instanciar las clases
        # Al querer compararlas por id
    end

    def tabla
        @tabla ||= Tabla.new(self)
        @tabla
    end

    private
    def persistibles_heredados
        (superclass == BasicObject)? {} : superclass.atributos_persistibles
    end

    def subclasses
        @subclases||{}
    end

    def trying_to_find?(metodo)
        metodo.to_s.start_with?("find_by_")
    end

    def parse_find_by(mensaje)
        mensaje.to_s.delete_prefix("find_by_").to_sym
    end

    def is_property?(property)
        method_defined?(property) and instance_method(property).arity.eql? 0
    end

    def validar_busqueda(property)
        raise "#{property.to_s} no es una property de la clase #{self.to_s}" unless is_property?(property)
    end

    def method_missing(method, *args)
        if trying_to_find?(method)
            property = parse_find_by(method)
            validar_busqueda(property)
            return all_instances.select{|i| i.send(property)==args.first}
        end

        super
    end

    def respond_to_missing?(*args)
        metodo = args.first
        trying_to_find?(metodo) or super
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