require 'a_utils'
require 'tadb'

class Tabla
    def initialize(clase)
        @clase = clase
        @tablaTADB = TADB::DB.table(@clase.to_s)
    end

    def persist(objeto)

        if objeto.id.nil?
            insert(objeto)
        else
            update(objeto)
        end
    end

    def remove(objeto)
        @tablaTADB.delete(objeto.id)
    end


    def find_by(atributo, valor)
        find_entries_by(atributo, valor).map{|fila| to_instance(fila)}
    end

    def get_all
        @tablaTADB.entries.map {|entry| to_instance(entry)}
    end

    def recuperar_de_db(objeto)
        datos = find_entries_by(:id, objeto.id).first

        if datos.nil?
            raise 'no se encontro objeto'
        end

        asignar_datos(objeto, datos)
    end

    private
    def insert(objeto)
        id = @tablaTADB.insert(formato_fila(objeto))
        objeto.id = id
    end

    def update(objeto)
        id = objeto.id
        fila = formato_fila(objeto).merge({:id=>id})
        @tablaTADB.delete(id)
        @tablaTADB.insert(fila)
    end

    def formato_fila(objeto)
        fila = {}
        objeto.atributos_persistibles.each do
            |atr|
            nombre=atr[:nombre]
            tipo=atr[:tipo]
            valor = atr[:valor]

            tipo.agregar_a_fila(nombre, valor, fila)
        end

        #Hash[atributos.collect{|e| [e[:nombre], e[:valor]]}]
        fila
    end

    def to_instance(fila)
        arity = @clase.instance_method(:initialize).arity.abs
        *args = [nil]*arity
        instancia = @clase.new(*args)

        asignar_datos(instancia, fila)

        return instancia
    end

    def asignar_datos(objeto, datos)
        datos.each do |key, value|

            if (key.param?)
                clase = Object.const_get(value)
                key = ((key.to_s)[1..-1]).to_sym
                value = clase.find_by_id(datos[key]).first
            end

            objeto.instance_variable_set(key.to_param, value)
        end
    end

    def find_entries_by(atributo, valor)
        @tablaTADB.entries.select{|e| e[atributo]==valor}
    end
end