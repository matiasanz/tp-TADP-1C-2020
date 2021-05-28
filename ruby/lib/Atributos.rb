require_relative 'Util'

# clase abstracta
class Atributo

  include Util

  attr_accessor :nombre, :tipo

  def initialize(nombre, tipo)
    @nombre = nombre
    @tipo = tipo
  end

end

class AtributoSimple < Atributo

  def initialize(nombre, tipo)
    if es_tipo_primitivo(tipo)
      self.extend(SimpleBasico) # se inserta entre la instancia y su clase -> Instancia, SimpleBasico, AtributoSimple
    else
      self.extend(SimpleComplejo)
    end
    super(nombre, tipo)
  end

end

module SimpleBasico

  def obtener_valor_para_insertar(valor)
    valor
  end

  def settear(instancia)
    valor_a_settear = instancia.class.hash_atributos_persistidos(instancia.id)[@nombre]
    instancia.send(pasar_a_setter(@nombre), valor_a_settear)
  end
end

module SimpleComplejo

  def obtener_valor_para_insertar(valor)
    valor.save!.id
  end

  def settear(instancia)
    valor_a_settear = @tipo.find_by_id(instancia.class.hash_atributos_persistidos(instancia.id)[@nombre])[0]
    instancia.send(pasar_a_setter(@nombre), valor_a_settear)
  end
end

class AtributoMultiple < Atributo

  def initialize(nombre, tipo)
    if es_tipo_primitivo(tipo)
      self.extend(MultipleBasico)
    else
      self.extend(MultipleComplejo)
    end
    super(nombre, tipo)
  end

  def array_persistido(instancia)
    instancia.class.hash_atributos_persistidos(instancia.id)[@nombre].split(",")
  end

end

module MultipleBasico

  def obtener_valor_para_insertar(valor)
    valor.join(",")
  end

  def settear(instancia)
    instancia.send(pasar_a_setter(@nombre), [])
    array_persistido_primitivo(instancia).each do |valor|
      instancia.send(pasar_a_setter(@nombre), instancia.send(@nombre).push(valor))
    end
    self
  end

  def array_persistido_primitivo(instancia)
    if @tipo == Numeric
      array_persistido(instancia).map{ |elem| elem.to_i }
    elsif @tipo == Boolean
      array_persistido(instancia).map{ |elem| elem == "true" ? true : false }
    else
      array_persistido(instancia)
    end
  end

end

module MultipleComplejo

  def obtener_valor_para_insertar(valor)
    valor.map{|instancia| instancia.save!.id}.join(",")
  end

  def settear(instancia)
    instancia.send(pasar_a_setter(@nombre), [])
    array_persistido(instancia).each do |id|
      instancia.send(pasar_a_setter(@nombre), instancia.send(@nombre).push(@tipo.find_by_id(id)[0]))
    end
    self
  end

end
