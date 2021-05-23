require 'tadb'
require 'b_atributos_persistibles'

class Tabla
    def initialize(clase)
        @clase = clase
        @tablaTADB = TADB::DB.table(@clase.to_s)
    end

    #Se usa en save!
    def persist(objeto)
        @tablaTADB.delete(objeto.id)
        id = @tablaTADB.insert(formato_entrada(objeto))
        objeto.id = id
    end

    #Se usa en forget!
    def remove(objeto)
        @tablaTADB.delete(objeto.id)
    end

    #Actualmente se usa solo para el id. Ver si vale la pena dejar
    def find_by(atributo, valor)
        find_entries_by(atributo, valor).map{|fila| to_instance(fila)}
    end

    #Se usa en all_instances
    def get_all
        @tablaTADB.entries.map {|entry| to_instance(entry)}
    end

    #Se usa en refresh!
    def recuperar_de_db(objeto)
        datos = find_entries_by(:id, objeto.id).first

        if datos.nil?
            raise ObjetoNoPersistidoException.new(objeto)
        end

        asignar_datos(objeto, datos)
    end

    private
    def formato_entrada(objeto)
        entrada = {}

        @clase.atributos_persistibles.each do
            |nombre, atributo|
            persistible = objeto.send(nombre)
            atributo.agregar_a_entrada(persistible, entrada) unless persistible.nil?
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
            |nombre, atributo|
            valor = atributo.recuperar_de_fila(datos, objeto)
            objeto.send("#{nombre.to_s}=", valor)
        end
    end

    def find_entries_by(nombre, valor)
        @tablaTADB.entries.select{|e| e[nombre]==valor}
    end
end

class TablaMultiple
    def initialize(tipo, claseCompuesta, parametro)
        @clase = tipo
        @tablaTADB = TADB::DB.table("#{claseCompuesta.to_s}_#{parametro.to_s}")
    end

    def insert(fila)
        @tablaTADB.insert(fila)
    end

    def delete_elements(duenio)
        get_entradas_de_objeto(duenio).each{|e| @tablaTADB.delete(e[:id])}
    end

    def get_entradas_de_objeto(objeto)
        @tablaTADB.entries.select{|e| e[:idDuenio]==objeto.id}
    end
end