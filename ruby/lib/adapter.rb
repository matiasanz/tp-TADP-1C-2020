require 'utils'
require 'tadb'

class Tabla
    def initialize(clase)
        @clase = clase
        @tablaTADB = TADB::DB.table(@clase.to_s)
    end

    def persist(objeto)
        atributos = objeto.atributos_persistibles()

        nuevaFila = Hash[atributos.collect{|e| [e[:nombre], e[:valor]]}]

        if objeto.id.nil?
            insert(objeto, nuevaFila)
        else
            update(objeto, nuevaFila)
        end
    end

    def delete(objeto)
        @tablaTADB.delete(objeto.id)
    end

    def find_by(atributo, valor)
        all_instances.select{|i| i.instance_variable_get(atributo.to_param)==valor}
    end

    def all_instances()
        @tablaTADB.entries.map do
            |entry|
            instancia = @clase.new #(args)
            #*args = [nil]*@clase.method(:initialize).arity.abs
            asignar_datos(instancia, entry)

            instancia
        end
    end

    def asignar_datos(objeto, datos)
        datos.each { |key, value| objeto.instance_variable_set(key.to_param, value) }
    end

    def recuperar_de_db(objeto)
        datos = @tablaTADB.entries().select{|e| e[:id]==objeto.id}.first
        asignar_datos(objeto, datos)
    end

    private
    def insert(objeto, fila)
        id = @tablaTADB.insert(fila)
        objeto.id = id
    end

    def update(objeto, fila)
        id = objeto.id
        fila[:id] = id
        @tablaTADB.delete(id)
        @tablaTADB.insert(fila)
    end
end