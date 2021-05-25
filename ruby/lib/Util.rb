module Util

  def es_atributo_has_many(atributos, simbolo)
    atributos[:has_many] && atributos[:has_many].include?(simbolo)
  end

  def atr_persistibles_sin_has_many(atributos)
    atributos_persistibles_temp = atributos.clone
    atributos_persistibles_temp.delete(:has_many)
    atributos_persistibles_temp
  end
end
