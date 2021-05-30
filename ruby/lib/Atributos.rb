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
    # TODO creo (pero no es necesario que lo cambies) que podrías usar solo 2 mixines
    # para los subtipos de atributos. Es decir, en vez de SimpleBasico, MultipleBasico, con solo un Basico
    # podrías generalizar la logica (porque son bastante parecidos)
    if es_tipo_primitivo(tipo) then extend(SimpleBasico) else extend(SimpleComplejo) end
    super(tipo, params) # se inserta entre la instancia y su clase -> Instancia, SimpleBasico, AtributoSimple
  end

  def validar_todo(valor, nombre_clase_error)
    @validador.validar(valor, nombre_clase_error)
    self
  end

end

module SimpleBasico

  def obtener_valor_para_insertar(dato, _)
    dato
  end

  def settear(instancia)
    setter_generico(instancia, valor_persistido(instancia))
    self
  end

end

module SimpleComplejo

  def obtener_valor_para_insertar(dato, _)
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
    self
  end

  def tabla_intermedia(nomb_clase_instancia)
    @tabla ||= TADB::DB.table("#{nomb_clase_instancia}-X-#{@tipo_atributo.name}")
  end

  private

  def obtener_valor_para_insertar(array, nomb_clase_instancia, &bloque)
    array = array.clone
    array = array.map { |e| @default if e.nil? } if array[0].nil? && !@default.nil?
    id_estable = tabla_intermedia(nomb_clase_instancia).insert({ valor:bloque.call(array[0]) } )
    array.delete_at(0)
    array.each { |e| tabla_intermedia(nil).insert({ id:id_estable, valor:bloque.call(e) } ) } unless array.nil?
    id_estable
  end

  def settear(instancia, &bloque)
    setter_generico(instancia, [])
    id_estable = valor_persistido(instancia)
    array_entradas = tabla_intermedia(nil).entries.select { |entrada| entrada.has_value?(id_estable) }
    array_valores = array_entradas.map { |hash| hash[:valor] }
    array_valores.each { |valor| setter_generico(instancia, instancia.send(@nombre).push(bloque.call(valor))) }
    self
  end

end

module MultipleBasico

  def obtener_valor_para_insertar(array, nomb_clase_instancia)
    super(array, nomb_clase_instancia) { |e| e }
  end

  def settear(instancia)
    super(instancia) { |elem| elem }
    self
  end

end

module MultipleComplejo

  def obtener_valor_para_insertar(array, nomb_clase_instancia)
    super(array, nomb_clase_instancia) { |e| e.save!.id }
  end

  def settear(instancia)
    super(instancia) { |elem| @tipo_atributo.find_by_id(elem)[0] }
    self
  end

end
