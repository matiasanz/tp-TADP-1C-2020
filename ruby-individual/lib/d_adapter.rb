require 'tadb'
require 'b_atributos_persistibles'

module ORM
    class Tabla

        def self.new_tabla_unica(tipo)
            new(tipo, tipo.to_s)
        end

        def self.new_tabla_multiple(tipo, claseCompuesta, parametro)
            new(tipo, "#{claseCompuesta.to_s}_#{parametro.to_s}")
        end

        def initialize(clase, nombre)
            @clase = clase
            @tablaTADB = TADB::DB.table(nombre)
        end

        #Se usa en save!
        def save(objeto)
            @tablaTADB.delete(objeto.id) unless  objeto.id.nil?
            id = insert(formato_entrada(objeto))
            objeto.id = id
        end

        #Se usa en forget!
        def forget(objeto)
            @tablaTADB.delete(objeto.id)
        end

        #Actualmente se usa solo para el id. Ver si vale la pena dejar
        def find_by(atributo, valor)
            find_entries_by(atributo, valor).map{|fila| to_instance(fila)}
        end

        #Se usa en all_instances
        def get_all_instances
            @tablaTADB.entries.map {|entry| to_instance(entry)}
        end

        #Se usa en refresh!
        def refresh(objeto)
            datos = find_entries_by(:id, objeto.id).first

            if datos.nil?
                raise ObjetoNoPersistidoException.new(objeto)
            end

            asignar_datos(objeto, datos)
        end

        #Lo que sigue se usa en los atributos multiples
        def insert(fila)
            @tablaTADB.insert(fila)
        end

        def delete_elements(duenio)
            get_entradas_de_objeto(duenio).each{|e| @tablaTADB.delete(e[:id])}
        end

        def get_entradas_de_objeto(objeto)
            find_entries_by(:idDuenio, objeto.id)
        end
        private
        def formato_entrada(objeto)
            entrada = {}

            @clase.atributos_persistibles.each_value do
                |atributo|
                persistible = atributo.get_from(objeto)
                atributo.agregar_a_entrada(persistible, entrada) unless persistible.nil?
            end

            entrada
        end

        def to_instance(fila)
            *args = [nil]*aridad_constructor
            # TODO aca el *args funciona pero es medio hack, porque estás seteando
            # valores fruta con tal que no rompa hasta que llega la llamada del asignar_datos
            # y pisa con lo que tiene persistido jajaja
            # (no necesitas cambiarlo, es un tema no tan importante para el TP,
            # pero en un framework productivo lo tendrías que sacar)
            instancia = @clase.new(*args)
            asignar_datos(instancia, fila)
            instancia
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
            condicion = valor.is_a?(Proc)? valor: proc{|v| v==valor}
            @tablaTADB.entries.select {|e| e[nombre].instance_eval(&condicion)}
        end
    end
end