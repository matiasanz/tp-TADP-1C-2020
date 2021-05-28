require 'd_adapter'

module ClasePersistible

    def inherited(modulo)
        subclasses << modulo
    end

    def subclasses
        @subclases||=[]
    end

    def tabla
        @tabla||=Tabla.new_tabla_unica(self)
    end

    def persistibles_propios
        @atributos_persistibles||={}
    end

    #Enunciado
    def has_one(tipo, args)
        has_attribute(tipo, args, false)
    end

    def has_many(tipo, args)
        has_attribute(tipo, args, true)
    end

    private
    def has_attribute(tipo, args, many)
        validar_has_args(args)
        atributo = AtributoHelper.as_attribute(args, tipo, self, many)
        attr_accessor atributo.nombre
        persistibles_propios[atributo.nombre] = atributo
    end

    def validar_has_args(args)
        parametrosSobrantes = args.keys - [:named, :default, :from, :to, :no_blank, :validate]
        raise HasArgsException.new(parametrosSobrantes) unless parametrosSobrantes.empty?
    end

    public

    #Enunciado
    def all_instances
        tabla.get_all + subclasses.flat_map{|s| s.all_instances}
    end

    def atributos_persistibles
        persistibles_heredados.merge(persistibles_propios)
    end

    private
    def persistibles_heredados
        (superclass == BasicObject)? {} : superclass.atributos_persistibles
    end

    #Enunciado: Find by
    def method_missing(method, *args)
        if trying_to_find?(method)
            property = parse_find_by(method)
            validar_busqueda(property)
            return find_by(property, *args)
        end

        super
    end

    def respond_to_missing?(*args)
        metodo = args.first
        trying_to_find?(metodo) or super
    end

    # Metodos auxiliares ++++++++++++++++++++++++++++++++

    def trying_to_find?(metodo)
        metodo.to_s.start_with?("find_by_")
    end

    def parse_find_by(mensaje)
        mensaje.to_s.delete_prefix("find_by_").to_sym
    end

    def has_property?(property)
        method_defined?(property) and instance_method(property).arity.eql? 0
    end

    def validar_busqueda(property)
        raise PropertyNotFoundException.new(property, self) unless has_property?(property)
    end

    def entrada_de_tabla?(property)
        atributos_persistibles[property].is_a? AtributoSimple
    end

    protected
    def find_by(property, value)
        if entrada_de_tabla?(property)
            return tabla.find_by(property, value) + subclasses.flat_map{|c|c.find_by(property, value)}
        else
            return all_instances.select{|i| i.send(property)==value}
        end
    end
end
