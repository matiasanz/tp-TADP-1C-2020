require 'tadb'

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
end

class Tabla
    def initialize(clase)
        @clase = clase
        @tablaTADB = TADB::DB.table(@clase.to_s)
    end

    def persist(objeto)
        atributos = objeto.atributos_persistibles()

        nuevaFila = Hash[atributos.collect{|e| [e[:nombre], e[:valor]]}]

        id = @tablaTADB.insert(nuevaFila)

        objeto.id = id
    end

    def get_by(atributo, valor)
        all_instances.select{|i| i.instance_variable_get("@#{atributo.to_s}".to_sym)==valor}
    end

    def all_instances()
        @tablaTADB.entries.map do |entry|
            instancia = @clase.new
            entry.each { |key, value| instancia.instance_variable_set("@#{key.to_s}".to_sym, value) }
            instancia
        end
    end
end