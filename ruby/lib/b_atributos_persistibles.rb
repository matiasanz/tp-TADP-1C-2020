require_relative 'a_utils'
require 'exceptions'
require 'c_validador_de_atributos'
#*********** Selector **************

module AtributoHelper
    def self.clase_primitiva?(clase)
        [String, Boolean, Numeric].include?(clase)
    end

    def self.as_attribute(args, tipo, claseContenedora, many=false)

        raise ClaseDesconocidaException.new(tipo) unless tipo.is_a?(ClasePersistible) or clase_primitiva?(tipo)

        atributo = many ? AtributoMultiple.new(args[:named], tipo, args[:default], claseContenedora)
                       : as_simple_attribute(args[:named], tipo, args[:default])

        atributo.set_validador(ValidadorDeAtributo.new(tipo, args))

        return atributo
    end

    def self.as_simple_attribute(nombre, clase, default=nil)
        tipoAtributo = clase_primitiva?(clase)? AtributoSimple : AtributoCompuesto
        tipoAtributo.new(nombre, clase, default)
    end

end

#*********** Atributos Persistibles **************

#Abstracta
class AtributoPersistible
    attr_reader :nombre, :clase
    def initialize(nombre, clase, default=nil)
        @nombre=nombre
        @clase=clase
        validar_tipo(default)
        @default=default
    end

    def set_validador(validador)
        @validador = validador
    end

    def validar_instancia(valor)
        validar_tipo(valor)
        raise ValidadorNilException.new if @validador.nil?
        @validador.validar(self, valor)
    end

    def validar_tipo(objeto) #TODO Mover a validador
        raise TipoErroneoException.new(objeto, @clase) unless objeto.is_a? @clase or objeto.nil?
    end

    def set_default_on_empty(objeto)
        persistible = get_from(objeto)
        objeto.send("#{@nombre.to_s}=", @default) if persistible.nil?
    end

    #Persiste el atributo previo a que se salve el objeto
    def persistir_de(objeto)
        persistible = get_from(objeto)
        validar_instancia(persistible)
        persistir(persistible) unless persistible.nil?
    end

    def persistir_relaciones(objeto)
        #no hace nada
    end

    def clean_relations
        #no hace nada
    end

    def get_from(objeto)
        valorActual = objeto.send(@nombre)
        validar_tipo(valorActual)
        valorActual
    end

    protected
    def persistir(persistible)
        raise MetodoAbstractoException.new
    end
end

# Persistible simple *******************************
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

# Persistible Compuesto *******************************
class AtributoCompuesto < AtributoPersistible

    def agregar_a_entrada(objeto, fila)
        validar_tipo(objeto)
        fila[@nombre] = objeto.id
    end

    def persistir(persistible)
        persistible.save!
    end

    def recuperar_de_fila(fila, _)
        return @clase.find_by_id(fila[@nombre]).first
    end

    def validar_instancia(valorActual)
        super
        valorActual.validate! unless valorActual.nil?
    end
end

# Persistible Multiple *******************************

class AtributoMultiple < AtributoPersistible
    def initialize(nombre, tipo, default, claseContenedora)
        super(nombre, Array, [default])
        @atributo = AtributoHelper.as_simple_attribute(:elemento, tipo)

        @TablaMultiple = Tabla.new_tabla_multiple(tipo, claseContenedora, nombre)
    end

    def agregar_a_entrada(objeto, fila)
        #No hace nada
    end

    def persistir_relaciones(objeto)
        clean_relations(objeto)
        lista = get_from(objeto)
        lista.each do
            |elemento|
            nuevaEntrada = {:idDuenio=>objeto.id}
            @atributo.agregar_a_entrada(elemento, nuevaEntrada)
            @TablaMultiple.insert(nuevaEntrada)
        end unless lista.nil?
    end

    def clean_relations(duenio)
        @TablaMultiple.delete_elements(duenio)
    end

    def recuperar_de_fila(_, duenio)
        @TablaMultiple.get_entradas_de_objeto(duenio).map{|e| @atributo.recuperar_de_fila(e, duenio)}
    end

    def validar_instancia(valorActual)
        validar_tipo(valorActual)
        valorActual.each{|elem| @atributo.validar_instancia(elem)} unless valorActual.nil?
    end

    def set_validador(validador)
        @atributo.set_validador(validador)
    end

    private
    def persistir(lista)
        lista.to_a.each {|elemento| @atributo.persistir(elemento) }
    end
end