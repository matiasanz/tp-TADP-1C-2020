class Object

  def has_one(tipo_atributo, named:)
    @atributos_persistibles = [] if @atributos_persistibles.nil?

    posicion_array = -1
    @atributos_persistibles.each_with_index do |hash, posicion|
      posicion_array = posicion if hash.has_value?(named)
    end

    if posicion_array == -1
      @atributos_persistibles.push({ :tipo => tipo_atributo, :named => named })
    else
      @atributos_persistibles[posicion_array] = { :tipo => tipo_atributo, :named => named }
    end
  end

  #para test
  def tipo_de nombre_atributo
    nil if @atributos_persistibles.nil?

    posicion_array = -1
    @atributos_persistibles.each_with_index do |hash, posicion|
      posicion_array = posicion if hash.has_value?(nombre_atributo)
    end

    posicion_array == -1 ? nil : @atributos_persistibles[posicion_array][:tipo]
  end

end