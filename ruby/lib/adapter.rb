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
        @tablaTADB = TADB::DB.table(clase.to_s)
    end

    def persist(objeto)
        atributos = objeto.atributos_persistibles()
        #puts "ponele que inserto #{atributos.to_s}"

        nuevaFila = Hash[atributos.collect{|e| [e[:nombre], e[:valor]]}]

        id = @tablaTADB.insert(nuevaFila)

        objeto.id = id
    end
end