require 'b_atributos_persistibles'
require 'tadb'
require 'exceptions'

class Tabla
    def initialize(clase)
        @clase = clase
        @tablaTADB = TADB::DB.table(@clase.to_s)

        @NULL_VALUE="$NULL"
    end

    def persist(objeto)
        @tablaTADB.delete(objeto.id) unless objeto.id.nil?
        id = @tablaTADB.insert(formato_entrada(objeto))
        objeto.id = id
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
            raise ObjetoNoPersistidoException.new(objeto)
        end

        asignar_datos(objeto, datos)
    end

    private
    def formato_entrada(objeto)
        entrada = {}
        objeto.atributos_persistibles.each do
            |atributo, valor|
            atributo.agregar_a_entrada(valor, entrada)
        end

        id = objeto.id
        entrada.transform_values! {|v| v.nil?? @NULL_VALUE: v}
        entrada[:id] = id

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
            valor = atributo.recuperar_de_fila(datos)
            # TODO pueden delegar setear la variable directamente al "atributo"
            objeto.instance_variable_set(nombre.to_param, parse_nil(valor))
        end
    end

    def parse_nil(valor)
        (valor.is_a?(String) and valor.match(@NULL_VALUE))? nil: valor
    end

    def find_entries_by(nombre, valor)
        @tablaTADB.entries.select{|e| e[nombre]==valor}
    end
end