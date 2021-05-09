require 'tadb'
require 'utils'

class DataBase

    def initialize
        @tablas = {}
    end

    def get_tabla(clase)
        crear_tabla(clase) unless @tablas.has_key?(clase)
        @tablas[clase]
    end

    def crear_tabla(clase)
        @tablas[clase] = Tabla.new(clase)
    end

    def clear_all()
        TADB::DB.clear_all
    end
end

class Tabla
    def initialize(clase)
        @clase = clase
        @tablaTADB = TADB::DB.table(@clase.to_s)
    end

    def persist(objeto)
        atributos = objeto.atributos_persistibles()

        nuevaFila = Hash[atributos.collect{|e| [e[:nombre], e[:valor]]}]

        if objeto.id.nil?
            id = @tablaTADB.insert(nuevaFila)
            objeto.id = id
        else
            update(objeto, nuevaFila)
        end
    end

    def update(objeto, fila)
        id = objeto.id
        @tablaTADB.delete(id)
        fila[:id] = id
        @tablaTADB.insert(fila)
    end

    def get_by(atributo, valor)
        all_instances.select{|i| i.instance_variable_get(atributo.to_param)==valor}
    end

    def all_instances()
        @tablaTADB.entries.map do |entry|
            instancia = @clase.new
            entry.each { |key, value| instancia.instance_variable_set(key.to_param, value) }
            instancia
        end
    end
end