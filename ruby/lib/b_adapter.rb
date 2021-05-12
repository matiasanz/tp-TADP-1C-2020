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
            raise "el id del objeto #{objeto.to_s} no se corresponde con ninguno en la base de datos"
        end

        asignar_datos(objeto, datos)
    end

    private
    def insert(objeto)
        id = @tablaTADB.insert(formato_entrada(objeto))
        objeto.id = id
    end

    def update(objeto)
        fila = formato_entrada(objeto)
        @tablaTADB.delete(objeto.id)
        @tablaTADB.insert(fila)
    end

    def formato_entrada(objeto)
        entrada = {:id=>objeto.id}
        objeto.atributos_persistibles.each do
            |nombre, tipo, valor|
            tipo.agregar_a_entrada(nombre, valor, entrada)
        end
        entrada
    end

    def to_instance(fila)
        *args = [nil]*aridad_constructor
        instancia = @clase.new(*args)
        asignar_datos(instancia, fila)
        return instancia
    end

    def aridad_constructor
        @clase.instance_method(:initialize).arity.abs
    end

    def asignar_datos(objeto, datos)
        @clase.atributos_persistibles.each do
            |nombre, clase|
            valor = clase.recuperar_de_fila(nombre, datos)
            objeto.instance_variable_set(nombre.to_param, valor)
        end
    end

    def find_entries_by(atributo, valor)
        @tablaTADB.entries.select{|e| e[atributo]==valor}
    end
end