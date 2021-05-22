
module ClasePersistible

  attr_reader :atributos_persistibles
  attr_accessor :tabla

  def has_one(tipo_atributo, named:)
    relacion(tipo_atributo, named)
  end

  def has_many(tipo_atributo, named:)
    relacion(tipo_atributo, named)
    @atributos_persistibles[:has_many_attr] ||= []
    @atributos_persistibles[:has_many_attr].push(named)
  end

  def relacion(tipo_atributo, named)
    attr_accessor named
    @atributos_persistibles ||= {}
    @atributos_persistibles[named] = tipo_atributo
  end

  #para test
  def tipo_de(nombre_atributo)
    return nil if @atributos_persistibles.nil?
    if @atributos_persistibles.has_key?(nombre_atributo)
      return @atributos_persistibles[nombre_atributo]
    end
    nil
  end

  def all_instances
    return nil if @tabla.nil?
    @tabla.entries.map {|entrada| generar_instancia(entrada)}
  end

  def method_missing(mensaje, *args, &bloque)
    if respond_to?(mensaje, false)
      #naturalmente falla si el metodo tiene aridad != 0, porque asi esta definido en respond_to_missing?
      mensaje_a_enviar = mensaje.to_s.gsub("find_by_", "").to_sym
      all_instances.select {|instancia| instancia.send(mensaje_a_enviar) == args[0]}
    else
      super
    end
  end

  def respond_to_missing?(mensaje, priv = false)
    instancia = self.new
    mensaje_a_instancia = mensaje.to_s.gsub("find_by_", "").to_sym    #mini logica repetida en :method_missing arriba TODO. podria ser un util
    if instancia.respond_to?(mensaje_a_instancia, false)
      metodo = instancia.method(mensaje_a_instancia)
      metodo.arity == 0 || super
    else
      super
    end
  end

  # metodos auxiliares
  def generar_instancia(entrada_de_tabla)
    instancia = self.new
    instancia.send(:id=, entrada_de_tabla[:id])
    instancia.settear_atributos
  end

end
