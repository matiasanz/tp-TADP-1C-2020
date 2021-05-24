module ClasePersistible

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

  def inicializar_tabla
    @tabla = TADB::DB.table(name)
  end

  def insertar_en_tabla(hash)
    @tabla.insert(hash)
  end

  def borrar_de_tabla(id)
    @tabla.delete(id)
  end

  def hash_atributos_persistidos(id)
    @tabla.entries.each{ |entrada| return entrada if entrada.has_value?(id) }
    nil
  end

  def all_instances
    return nil unless @tabla
    @tabla.entries.map { |entrada| generar_instancia(entrada) }
  end

  def generar_instancia(entrada_de_tabla)
    instancia = self.new
    instancia.send(:id=, entrada_de_tabla[:id])
    instancia.settear_atributos
  end

  #naturalmente falla si el metodo tiene aridad != 0, porque asi esta definido en respond_to_missing?
  def method_missing(mensaje, *args, &bloque)
    if respond_to?(mensaje, false)
      all_instances.select do |instancia|
        instancia.send(sin_find_by_(mensaje)) == args[0]
      end
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
