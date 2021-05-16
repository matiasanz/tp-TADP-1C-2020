require 'c_adapter'

class Class

    # TODO traten de minimizar la cantidad de métodos que definen en Class (o contextos globales similares).
    # Agregar metodos (incluso "privados") afecta a todas las clases del sistema y pueden generar colisiones
    # con otras dependencias que quieren usar los mismos nombres.
    #
    # Una forma de evitarlo es pedirles a las clases que quieren usar el ORM que
    # incluyan un mixin o extiendan de una clase (generalmente la primera es más extensible).
    #
    # Otra opción es solo definir en Class o Module solo "has_one" y los demás métodos explicitamente requeridos
    # pero todos los que son "utils" mandarlos a un objeto externo fuera de class (ej. la clase que armaron para utils AtributoHelper)

    #Enunciado
    def has_one(tipo, named)
=begin
TODO
    Cambien el formato de "named" para que sea compatible con el formato definido en el
    enunciado (además de "named" van a proveerles más opciones en este parámetro).
    Ruby tiene un formato especial de parametros que lo traduce a Hash (mapa):
    class A
      def x(w)
        puts(w)
        w
      end
    end
    A.new.x(pepe: :lala).class
    {:pepe=>:lala}
    => Hash
    Esto les va a permitir incluir las features pedidas al final del enunciado (sino van a
     tener algunos problemas para adaptar la interfaz cuando algunos atributos el usuario
     no quiere definirlos y no van a saber cual es cual)
=end
        if @atributos_persistibles.nil?
            # TODO les conviene usar un metodo que les retorne el hash vacío cuando
            # @atributos_persistibles no está definido (sino cada vez que quieran
            # usar @atributos_persistibles tienen que preguntar por nil)
            # Es más o menos común hacer algo como `@atributos_persistibles || {}` o
            # `@atributos_persistibles ||= {}`
            # (ahora estoy viendo que definieron `atributos_persistibles`, `persistibles_propios` y `persistibles_heredados`
            # pueden usar alguno de esos según corresponda)
            @atributos_persistibles = {}
        end
        @atributos_persistibles[named] = AtributoHelper.as_atribute(named, tipo)

        definir_find_by_(named, tipo)

        # TODO recuerden que luego de usar "has_one" debe ser posible usar getter y setters
        # sobre el atributo definido
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
        @atributos_persistibles.nil?? {} : @atributos_persistibles
    end

    def persistibles_heredados
        # TODO tengan en cuenta que si usan "superclass" en lugar de "super"
        # los mixines (Module) que existan en el medio de la herencia no van a
        # participar del lookup (es decir, atributos que un module defina van a ser
        # ignorados)
        (superclass == BasicObject)? {} : superclass.atributos_persistibles
    end

    def definir_find_by_(named, clase)
        # TODO no es una mala alternativa definir explicitamente el método
        # "find_by_X" para cada atributo persistible, pero recuerden que tienen
        # que soportar por ejemplo el "id" que está implicito en todas las
        # clases persistibles (find_by_id) y también metodos que no reciben parámetros
        # (como el ejemplo del enunciado "Student.find_by_promoted").
        # Ustedes lo tienen implicitamente definido para TODOS los objetos de ruby
        # porque lo pusieron sobre Object (esto es un poco agresivo porque no todos los objetos
        # son persistibles).
        #
        # Otra alternativa es usar "method missing" y cuando te llaman, parsear el nombre
        # del mensaje, extraer el nombre del atributo buscado y hacer en ese momento
        # una busqueda contra la tabla.
        get_real_value = AtributoHelper.clase_primitiva?(clase)?
            lambda{|valor| valor} : lambda{|objeto| objeto.id}

        define_singleton_method("find_by_#{named.to_s}".to_sym) do
            |valor|
            tabla.find_by(named, get_real_value.call(valor))
        end
    end
end

class Object

    has_one String, :id

    # TODO "attr_accessor :id" es redundante con has_one (has_one debería darte los accessors)
    attr_accessor :id

=begin
    TODO Para evitar contaminar Object, es recomendable que solo las instancias
     de las clases "persistibles" entiendan estos mensajes.
     "Nota: No todos los objetos necesitan implementar estas operaciones, sólo aquellos que
     queramos persistir. La forma de identificar a estos tipos queda a criterio de cada grupo."
     Si necesitan ayuda definiendo las alternativas que hay para conseguir esto no duden en avisarme
=end

    #Enunciado
    def save!
        # TODO podrían agregar una validación para que solo los objetos persistibles
        # entiendan el "save!"
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
        # TODO tiene que retornar la instancia (self) para usarlo encadenado con otros mensajes
    end

    # TODO cuidado con esta interfaz / contrato. La clase "persistible"
    # retorna un hash de "nombre de property" -> "AtributoPersistible"
    # pero si el mismo mensaje se lo mandan a una instancia retorna
    # un hash de "AtributoPersistible" -> valor de la variable de instancia
    def atributos_persistibles
        self.class.atributos_persistibles
            .map do |nombre, atributo|
            # TODO aca podrían delegar como obtener el valor del atributo directamente
            # al atributo (es decir, podría ser responsabilidad del atributo
            # saber como obtener y construir el valor de una property)
            # (es una opción de diseño, no es un cambio requerido, analicen cual les resulta
            # mejor)
                [atributo, instance_variable_get(nombre.to_param)]
            end
    end

    private
    def tabla
        self.class.tabla
    end
end