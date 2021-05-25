require_relative 'Util'

module ClasePersistible

  include Util

  attr_reader :atributos_persistibles
  attr_accessor :tabla

  def has_one(tipo_atributo, named:)
    agregar_atributo(tipo_atributo, named)
  end

  def has_many(tipo_atributo, named:)
    agregar_atributo(tipo_atributo, named)
    @atributos_persistibles[:has_many] ||= []
    @atributos_persistibles[:has_many].push(named)
  end

  def agregar_atributo(tipo_atributo, named)
    attr_accessor named
    @atributos_persistibles ||= {}
    @atributos_persistibles[named] = tipo_atributo
  end

  #def definir_getter(named)
  #  send(:define_method, named) do
  #    obj.instance_variable_set("@#{named.to_s}".to_sym, [])
  #  end
  #end

  def analizar_ancestros
    ancestros = []
    ancestors.each do |ancestro|
      break if ancestro == ORM
      ancestros.push(ancestro) if ancestro.is_a?(ClasePersistible)
    end
    ancestros.delete_at(0)
    agregar_atributos_de_ancestros(ancestros) if ancestros.size > 0
    self
  end

  def agregar_atributos_de_ancestros(ancestros)
    ancestros.reverse!
    atr_persistibles_original = @atributos_persistibles.clone
    ancestros.each { |modulo| agregar_atributos_de(modulo.atributos_persistibles) }
    agregar_atributos_de(atr_persistibles_original)
    @atributos_persistibles[:has_many] = @atributos_persistibles[:has_many].uniq if @atributos_persistibles[:has_many]
    self
  end

  def agregar_atributos_de(hash_atributos)
    atr_persistibles_sin_has_many(hash_atributos).each do |nombre, tipo|
      if es_atributo_has_many(hash_atributos, nombre)
        has_many(tipo, named: nombre)
      else
        has_one(tipo, named: nombre)
      end
    end
    self
  end

  def inicializar_tabla
    @tabla = TADB::DB.table(name)
    analizar_ancestros # tambien agrega atributos de clases padre
    self
  end

  def insertar_en_tabla(hash)
    @tabla.insert(hash)
  end

  def borrar_de_tabla(id)
    @tabla.delete(id)
    self
  end

  def hash_atributos_persistidos(id)
    @tabla.entries.each{ |entrada| return entrada if entrada.has_value?(id) }
    nil
  end

  def all_instances
    if @tabla
      all_instances_de_hijos + @tabla.entries.map { |entrada| generar_instancia(entrada) }
    else
      if is_a?(Class)
        []
      else
        all_instances_de_hijos
      end
    end
  end

  def all_instances_de_hijos
    array_aux = []
    modulos_hijos.each { |modulo| array_aux = array_aux + modulo.all_instances }
    array_aux
  end

  def generar_instancia(entrada_de_tabla)
    instancia = self.new
    instancia.send(:id=, entrada_de_tabla[:id])
    instancia.settear_atributos
  end

  #naturalmente falla si el metodo tiene aridad != 0, porque asi esta definido en respond_to_missing?
  def method_missing(mensaje, *args, &bloque)
    if respond_to?(mensaje, false)
      all_instances.select { |instancia| instancia.send(sin_find_by_(mensaje)) == args[0] }
    else
      super
    end
  end

  def respond_to_missing?(mensaje, priv = false)
    instancia = self.new
    if instancia.respond_to?(sin_find_by_(mensaje), false)
      metodo = instancia.method(sin_find_by_(mensaje))
      metodo.arity == 0 || super
    else
      super
    end
  end

  def sin_find_by_(mensaje)
    mensaje.to_s.gsub("find_by_", "").to_sym
  end

end
