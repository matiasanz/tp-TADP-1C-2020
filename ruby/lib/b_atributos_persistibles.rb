require_relative 'a_utils'
require 'exceptions'

#*********** Selector **************

module AtributoHelper
    def self.clase_primitiva?(clase)
        [String, Boolean, Numeric].include?(clase)
    end

    def self.as_atribute(nombre, clase)
        clase_primitiva?(clase)? AtributoSimple.new(nombre, clase) : AtributoCompuesto.new(nombre, clase)
    end
end

#*********** Atributos Persistibles **************

#Abstracta
class AtributoPersistible
    def initialize(nombre, clase)
        raise ClaseDesconocidaException.new(clase) unless clase.is_a?(Module)
        @nombre=nombre
        @clase=clase
    end

    def validar_tipo(objeto)
        raise TipoErroneoException.new(objeto, @clase) unless objeto.is_a? @clase or objeto.nil?
    end

    def persistir_de(objeto)
        persistible = get_from(objeto)
        persistir(persistible) unless persistible.nil?
    end

    def persistir(persistible)
        raise 'debe implementar'
    end

    def get_from(objeto)
        valorActual = objeto.send(@nombre)
        validar_tipo(valorActual)
        valorActual
    end

    def commit(objeto)
        #no hace nada
    end
end

class AtributoSimple < AtributoPersistible
    def agregar_a_entrada(valor, entrada)
        validar_tipo(valor)
        entrada[@nombre] = valor
    end

    def recuperar_de_fila(fila, _)
        fila[@nombre]
    end

    def persistir(objeto)
        #no hace nada
    end
end

class AtributoCompuesto < AtributoPersistible
    def agregar_a_entrada(objeto, fila)
        validar_tipo(objeto)
        fila[@nombre] = objeto.id
    end

    def recuperar_de_fila(fila, _)
        return @clase.find_by_id(fila[@nombre]).first
    end

    def persistir(persistible)
        persistible.save!
    end
end

class AtributoMultiple < AtributoPersistible
    def initialize(nombre, tipo, claseCompuesta)
        super(nombre, Array)
        @atributo = AtributoHelper.as_atribute(:elemento, tipo)
        @TablaMultiple = TablaMultiple.new(tipo, claseCompuesta, nombre)
    end

    def agregar_a_entrada(objeto, fila)
        #no hace nada
    end

    def commit(objeto)
        clean(objeto)
        lista = get_from(objeto)
        lista.each do
            |elemento|
            nuevaEntrada = {:idDuenio=>objeto.id}
            @atributo.agregar_a_entrada(elemento, nuevaEntrada)
            @TablaMultiple.insert(nuevaEntrada)
        end unless lista.nil?
    end

    def clean(objeto)
        @TablaMultiple.delete_by_duenio(objeto)
    end

    def recuperar_de_fila(_, duenio)
        @TablaMultiple.get_entradas_de_objeto(duenio).map{|e| @atributo.recuperar_de_fila(e, duenio)}
    end

    private
    def persistir(lista)
        lista.to_a.each {|elemento| @atributo.persistir(elemento) }
    end
end
