require_relative 'Util'

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
    super(nombre, tipo)
  end

  def obtener_valor_para_insertar(valor)
    if es_tipo_primitivo(@tipo)
      valor
    else
      valor.save!.id
    end
  end

  def settear(instancia)
    if es_tipo_primitivo(@tipo)
      valor_a_settear = instancia.class.hash_atributos_persistidos(instancia.id)[@nombre]
    else
      valor_a_settear = @tipo.find_by_id(instancia.class.hash_atributos_persistidos(instancia.id)[@nombre])[0]
    end
    instancia.send(pasar_a_setter(@nombre), valor_a_settear)
  end


end

class AtributoMultiple < Atributo

  def initialize(nombre, tipo)
    super(nombre, tipo)
  end

  def obtener_valor_para_insertar(valor)
    if es_tipo_primitivo(@tipo)
      valor.join(",")
    else
      valor.map{|instancia| instancia.save!.id}.join(",")
    end
  end

  def settear(instancia)
    instancia.send(pasar_a_setter(@nombre), [])
    if es_tipo_primitivo(@tipo)
      array_persistido_primitivo(instancia).each do |valor|
        instancia.send(pasar_a_setter(@nombre), instancia.send(@nombre).push(valor))
      end
    else
      array_persistido(instancia).each do |id|
        instancia.send(pasar_a_setter(@nombre), instancia.send(@nombre).push(@tipo.find_by_id(id)[0]))
      end
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

  def array_persistido(instancia)
    instancia.class.hash_atributos_persistidos(instancia.id)[@nombre].split(",")
  end

end

#class AtributoCompuesto < Atributo

#  attr_accessor :atributo

#  def initialize(nombre, tipo)
#    super(nombre, tipo)
#  end

#  def obtener_valor_para_insertar(valor)

#  end

#end
