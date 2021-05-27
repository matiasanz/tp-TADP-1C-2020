module Util

  private
  def es_atributo_has_many(atributos_has_many, simbolo)
    atributos_has_many && atributos_has_many.include?(simbolo)
  end

  def sin_find_by_(mensaje)
    mensaje.to_s.gsub("find_by_", "").to_sym
  end

  def es_tipo_primitivo(clase)
    clase == String || clase == Numeric || clase == Boolean
  end

  def pasar_a_setter(simbolo)
    (simbolo.to_s << "=").to_sym
  end

end

module Boolean
end

class TrueClass
  include Boolean
end

class FalseClass
  include Boolean
end
