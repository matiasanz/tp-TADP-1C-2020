require_relative 'Util'
require_relative 'ValidadorAtributos'

# "CLASE ABSTACTA"

class Atributo

  include Util

  attr_reader :nombre, :tipo_atributo, :default

  def initialize(tipo, params, entidad_contenedora)
    @nombre = params[:named]
    @tipo_atributo = tipo
    @default = params[:default]
    @validador = ValidadorAtributos.new(params, tipo)
    @entidad_contenedora = entidad_contenedora
  end

  def valor_persistido(instancia)
    if instancia.class.hash_atributos_persistidos(instancia.id).nil?
      nil
    else
      instancia.class.hash_atributos_persistidos(instancia.id)[@nombre]
    end
  end

  private

  def setter_generico(instancia, valor_a_settear)
    instancia.send(pasar_a_setter(@nombre), valor_a_settear)
    self
  end

end

# ATRIBUTO SIMPLE <-------------------------------------

class AtributoSimple < Atributo

  def initialize(tipo, params, clase_contenedora)
    # TODO creo (pero no es necesario que lo cambies) que podrías usar solo 2 mixines
    # para los subtipos de atributos. Es decir, en vez de SimpleBasico, MultipleBasico, con solo un Basico
    # podrías generalizar la logica (porque son bastante parecidos)
    if es_tipo_primitivo(tipo) then extend(SimpleBasico) else extend(SimpleComplejo) end
    super(tipo, params, clase_contenedora) # se inserta entre la instancia y su clase -> Instancia, SimpleBasico, AtributoSimple
  end

  def validar_todo(valor, nombre_clase_error)
    @validador.validar(valor, nombre_clase_error)
    self
  end

end

module SimpleBasico

  def obtener_valor_para_insertar(dato, _)
    if dato.nil?
      return @default unless @default.nil?
      nil
    else
      dato
    end
  end

  def settear(instancia)
    setter_generico(instancia, valor_persistido(instancia))
    self
  end

end

module SimpleComplejo

  def obtener_valor_para_insertar(dato, _)
    if dato.nil?
      return @default.save!.id unless @default.nil?
      nil
    else
      dato.save!.id
    end
  end

  def settear(instancia)
    setter_generico(instancia, @tipo_atributo.find_by_id(valor_persistido(instancia))[0])
    self
  end

end

# ATRIBUTO MULTIPLE <-------------------------------------

class AtributoMultiple < Atributo

  def initialize(tipo, params, clase_contenedora)
    if es_tipo_primitivo(tipo) then extend(MultipleBasico) else extend(MultipleComplejo) end
    super(tipo, params, clase_contenedora)
  end

  def validar_todo(valor, nombre_clase_error)
    valor.each { |instancia| @validador.validar(instancia, nombre_clase_error) }
    self
  end

  private

  def tabla_intermedia
    @tabla ||= TADB::DB.table("#{@entidad_contenedora}-X-#{@nombre.to_s}")
  end

  def obtener_valor_para_insertar(array_original, instancia, &bloque)
    return nil if array_original.empty?
    array = sacar_nulos(array_original)
    id_anterior = valor_persistido(instancia)
    if id_anterior.nil?
      id_estable = tabla_intermedia.insert({ valor:bloque.call(array[0]) } )
      array.delete_at(0)
      array.each { |e| tabla_intermedia.insert({ id:id_estable, valor:bloque.call(e) } ) }
      id_estable
    else
      id_anterior = tabla_intermedia.entries[0][:id]
      array.each { |e| tabla_intermedia.insert({ id:id_anterior, valor:bloque.call(e) } ) }
      id_anterior
    end
  end

  def sacar_nulos(array)
    if @default.nil?
      array.compact
    else
      array.map { |e| @default if e.nil? }
    end
  end

  def settear(instancia, &bloque)
    setter_generico(instancia, [])
    id_estable = valor_persistido(instancia)
    array_entradas = tabla_intermedia.entries.select { |entrada| entrada.has_value?(id_estable) }
    array_valores = array_entradas.map { |hash| hash[:valor] }
    array_valores.each { |valor| setter_generico(instancia, instancia.send(@nombre).push(bloque.call(valor))) }
    self
  end

end

module MultipleBasico

  def obtener_valor_para_insertar(array, instancia)
    super(array, instancia) { |e| e }
  end

  def settear(instancia)
    super(instancia) { |elem| elem }
    self
  end

end

module MultipleComplejo

  def obtener_valor_para_insertar(array, instancia)
    super(array, instancia) { |e| e.save!.id }
  end

  def settear(instancia)
    super(instancia) { |elem| @tipo_atributo.find_by_id(elem)[0] }
    self
  end

end
