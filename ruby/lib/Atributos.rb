require_relative 'Util'
require_relative 'ValidadorAtributos'

# "CLASE ABSTACTA"

class Atributo

  include Util

  attr_reader :nombre, :tipo_atributo, :default

  def initialize(tipo, params)
    @nombre = params[:named]
    @tipo_atributo = tipo
    @default = params[:default]
    @validador = ValidadorAtributos.new(params, tipo)
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

  def initialize(tipo, params)
    if es_tipo_primitivo(tipo) then extend(SimpleBasico) else extend(SimpleComplejo) end
    super(tipo, params) # se inserta entre la instancia y su clase -> Instancia, SimpleBasico, AtributoSimple
  end

  def validar_todo(valor, nombre_clase_error)
    @validador.validar(valor, nombre_clase_error)
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
    setter_generico(instancia, @tipo_atributo.find_by_id(valor_persistido(instancia))[0])
    self
  end

end


# ATRIBUTO MULTIPLE <-------------------------------------

class AtributoMultiple < Atributo

  def initialize(tipo, params)
    if es_tipo_primitivo(tipo) then extend(MultipleBasico) else extend(MultipleComplejo) end
    super(tipo, params)
  end

  def validar_todo(valor, nombre_clase_error)
    valor.each { |instancia| @validador.validar(instancia, nombre_clase_error) }
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
    if @tipo_atributo == Numeric
      valor_persistido(instancia).split(",").map{ |elem| elem.to_i }
    elsif @tipo_atributo == Boolean
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
    super(instancia){ |elem| @tipo_atributo.find_by_id(elem)[0] }
  end

end
