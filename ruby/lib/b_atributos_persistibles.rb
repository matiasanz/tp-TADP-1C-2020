require_relative 'a_utils'
require 'exceptions'
require 'c_validador_de_atributos'

module ORM
    #*********** Selector **************

    module AtributoHelper

        def self.as_attribute(args, tipo, claseContenedora, many=false)
            validar_clase_persistible(tipo)
            nombre = args.delete(:named)
            default = args.delete(:default)

            validador = ValidacionesFactory.from_args(tipo, args)#ValidadorDeAtributos.as_validadores(tipo, args)

            return many ? AtributoMultiple.new(nombre, tipo, validador, default, claseContenedora)
                         : as_simple_attribute(nombre, tipo, validador, default)
        end

        def self.as_simple_attribute(nombre, clase, validador, default=nil)
            tipoAtributo = clase_primitiva?(clase)? AtributoSimple : AtributoCompuesto
            tipoAtributo.new(nombre, clase, validador, default)
        end

        def self.validar_clase_persistible(tipo)
            raise ClaseDesconocidaException.new(tipo)   unless tipo.is_a? Module
            raise ClaseNoPersistibleException.new(tipo) unless tipo.is_a?(ModuloPersistible) or clase_primitiva?(tipo)
        end

        def self.clase_primitiva?(clase)
            # TODO reemplacé la condición para que soporte subclases (sino Float no era persistible y es primitiva)
            [String, Boolean, Numeric].any? {|valid| clase <= valid }
        end
    end

    #*********** Atributos Persistibles **************

    #Abstracta
    class AtributoPersistible
        attr_reader :nombre, :clase
        def initialize(nombre, clase, validador, default=nil)
            @nombre=nombre
            @clase=clase
            @validador=validador
            raise ValidadorNilException.new if @validador.nil?
            @default=default
            # TODO está muy bueno que estás validando el default
            validar_instancia(default) unless default.nil?
        end

        def validar_instancia(valor)
            @validador.validar(self, valor)
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
            #Por defecto no hace nada
        end

        def forget_relaciones!
            #no hace nada
        end

        def get_from(objeto)
            objeto.send(@nombre)
        end

        protected
        def persistir(persistible)
            raise MetodoAbstractoException.new
        end
    end

    # Persistible simple *******************************
    class AtributoSimple < AtributoPersistible

        def persistir(objeto)
            # En este caso no hace falta, ya que
            # se almacena directamente en la entrada
            # de la tabla
        end

        def agregar_a_entrada(valor, entrada)
            entrada[@nombre] = valor
        end

        def recuperar_de_fila(fila, _)
            fila[@nombre]
        end
    end

    # Persistible Compuesto *******************************
    class AtributoCompuesto < AtributoPersistible

        def persistir(persistible)
            persistible.save!
        end

        def agregar_a_entrada(objeto, fila)
            fila[@nombre] = objeto.id
        end

        def recuperar_de_fila(fila, _)
            @clase.find_by_id(fila[@nombre]).first
        end

        def validar_instancia(valorActual)
            super
            valorActual.validate! unless valorActual.nil?
        end
    end

    # Persistible Multiple *******************************

    class AtributoMultiple < AtributoPersistible

        def initialize(nombre, tipo, validador, default, claseContenedora)
            # TODO buen detalle utilizar el validador de atributos para hacer implicita la validación de que tiene que ser un array
            super(nombre, Array, ValidacionesFactory.from_args(Array, {}), default)
            @atributo = AtributoHelper.as_simple_attribute(:elemento, tipo, validador)
            @TablaMultiple = Tabla.new_tabla_multiple(tipo, claseContenedora, nombre)
        end

        def persistir(lista)
            lista.to_a.each {|elemento| @atributo.persistir(elemento) }
        end

        def agregar_a_entrada(objeto, fila)
            #No hace nada
        end

        def persistir_relaciones(objeto)
            forget_relaciones!(objeto) #elimino los elementos actuales con tal de no generar inconsistencias
            lista = get_from(objeto)
            lista.each do
            |elemento|
                nuevaEntrada = {:idDuenio=>objeto.id}
                @atributo.agregar_a_entrada(elemento, nuevaEntrada)
                @TablaMultiple.insert(nuevaEntrada)
            end unless lista.nil?
        end

        def recuperar_de_fila(_, duenio)
            @TablaMultiple.get_entradas_de_objeto(duenio).map{|e| @atributo.recuperar_de_fila(e, duenio)}
        end

        def forget_relaciones!(duenio)
            @TablaMultiple.delete_elements(duenio)
        end

        def validar_instancia(valorActual)
            super
            valorActual.each{|elem| @atributo.validar_instancia(elem)} unless valorActual.nil?
        end
    end
end