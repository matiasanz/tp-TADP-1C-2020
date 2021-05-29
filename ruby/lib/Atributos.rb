require_relative 'Util'

# "CLASE ABSTACTA"

class Atributo

  include Util

  attr_accessor :nombre, :tipo

  def initialize(nombre, tipo)
    @nombre = nombre
    @tipo = tipo
  end

  private
  def valor_persistido(instancia)
    instancia.class.hash_atributos_persistidos(instancia.id)[@nombre]
  end

  def setter_generico(instancia, valor_a_settear)
    instancia.send(pasar_a_setter(@nombre), valor_a_settear)
    self
  end

end


# ATRIBUTO SIMPLE <-------------------------------------

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

  def obtener_valor_para_insertar(dato)
    dato
  end

  def settear(instancia)
    setter_generico(instancia, valor_persistido(instancia))
    self
  end

end

module SimpleComplejo

  def obtener_valor_para_insertar(dato)
    dato.save!.id
  end

  def settear(instancia)
    setter_generico(instancia, @tipo.find_by_id(valor_persistido(instancia))[0])
    self
  end

end


# ATRIBUTO MULTIPLE <-------------------------------------

class AtributoMultiple < Atributo

  def initialize(nombre, tipo)
    if es_tipo_primitivo(tipo)
      self.extend(MultipleBasico)
    else
      self.extend(MultipleComplejo)
    end
    super(nombre, tipo)
  end

  private
  def settear(instancia, &bloque)
    setter_generico(instancia, [])
    array_persistido(instancia).each do |elem|
      setter_generico(instancia, instancia.send(@nombre).push(bloque.call(elem)))
    end
    self
  end

  def array_persistido(instancia)
    if @tipo == Numeric
      valor_persistido(instancia).split(",").map{ |elem| elem.to_i }
    elsif @tipo == Boolean
      valor_persistido(instancia).split(",").map{ |elem| elem == "true" ? true : false }
    else
      valor_persistido(instancia).split(",")
    end
  end

end

module MultipleBasico

  def obtener_valor_para_insertar(dato)
    dato.join(",")
  end

  def settear(instancia)
    super(instancia){ |elem| elem }
  end

end

module MultipleComplejo

  def obtener_valor_para_insertar(dato)
    dato.map{|instancia| instancia.save!.id}.join(",")
  end

  def settear(instancia)
    super(instancia){ |elem| @tipo.find_by_id(elem)[0] }
  end

end
