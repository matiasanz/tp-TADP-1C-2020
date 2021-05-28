require 'd_adapter'

module ORM  # el usuario debe incluir este modulo para poder usar nuestro ORM. Y hacer el require_relative ".." correspondiente

    def self.included(modulo)
        entregar_dependecias(modulo)
    end

    def self.entregar_dependecias(modulo)
        dependencias_modulos_y_clases(modulo)
        dependencias_de_clases(clase) if modulo.is_a?(Class)
    end

    private
    def dependencias_modulos_y_clases(modulo)
        modulo.extend(EntidadPersistible)   #logica que entienden los modulos y las clases
        modulo.module_eval do
            def self.included(otro_modulo)
                ORM::entregar_dependecias(otro_modulo)
                modulos_hijos.push(otro_modulo)
            end
        end
    end

    def dependencias_de_clases(clase)
        clase.include(InstanciaPersistible)
        clase.extend(AdministradorDeTabla)     #logica que solo entienden las clases
        clase.class_eval do
            # esto inicializa los atributos que usan has_many con un array vacio []. Tambien inicializa los defaults
            # si el usuario define un contructor, solo tiene que escribir "inicializar_atributos" (si lo usa)
            # si no define contructor, funciona TOD0 bien
            def initialize
                inicializar_atributos   #TODO ?
                super
            end

            def self.inherited(otra_clase)
                modulos_hijos.push(otra_clase)
            end

        end
    end

end

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
        (superclass.is_a? ClasePersistible)? superclass.atributos_persistibles: {}
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

module ObjetoPersistible
    extend ClasePersistible

    def self.included(modulo)
        modulo.extend ClasePersistible
        modulo.has_one String, named: :id
    end

    #Enunciado
    def save!
        set_defaults_on_empty
        save_attributes!
        tabla.persist(self)
        save_relations!
        self
    end

    #Enunciado
    def forget!
        each_persistible {|p| p.clean_relations}
        tabla.remove(self)
        self.id= nil
    end

    #Enunciado
    def refresh!
        tabla.recuperar_de_db(self)
        self
    end

    def validate!
        each_persistible do
            |atributo|
            valorActual = atributo.get_from(self)
            atributo.validar_instancia(valorActual)
        end
    end

    private
    def save_attributes!
        each_persistible {|atributo| atributo.persistir_de(self)}
    end

    def save_relations!
        each_persistible { |atributo| atributo.persistir_relaciones(self)}
    end

    def set_defaults_on_empty
        each_persistible {|atr| atr.set_default_on_empty(self)}
    end

    def each_persistible(&block)
        self.class.atributos_persistibles.each_value { |atributo| block.call(atributo) }
    end

    def tabla
        self.class.tabla
    end
end
