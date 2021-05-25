require 'tadb'
require_relative 'Excepciones'
require_relative 'Util'

module ObjetoPersistible

  include Util

  attr_reader :id

  def atributos_persistibles
    self.class.atributos_persistibles
  end

=begin
  # define metodos y accesors para las clases persistibles
  def self.included(clase)
    clase.singleton_class.send(:attr_reader, :atributos_persistibles)
    clase.singleton_class.send(:attr_accessor, :tabla)
  end
=end

  def save!
    raise SaveException.new(self) unless atributos_persistibles
    self.class.inicializar_tabla unless self.class.tabla
    hash = generar_hash_para_insertar
    forget! if @id
    @id = self.class.insertar_en_tabla(hash)
    self
  end

  def refresh!
    raise RefreshException.new(self) unless @id
    settear_atributos
    self
  end

  def forget!
    raise ForgetException.new(self) unless @id
    self.class.borrar_de_tabla(@id)
    @id = nil
    self
  end

  #se usaria asi
  #def initialize
  #  inicializar_has_many
  #  super
  #end
  def inicializar_atributos_has_many
    if atributos_persistibles[:has_many]
      atributos_persistibles[:has_many].each{ |simbolo| send(pasar_a_setter(simbolo), []) }
    end
    self
  end

  def generar_hash_para_insertar
    hash_para_insertar = {}
    atr_persistibles_sin_has_many(atributos_persistibles).each do |simbolo, clase|
      hash_para_insertar[simbolo] = obtener_valor_a_insertar(simbolo, clase)
    end
    hash_para_insertar[:id] = @id
    hash_para_insertar
  end

  def obtener_valor_a_insertar(simbolo, clase)
    valor = send(simbolo)
    if !valor
      ""
    elsif es_atributo_has_many(atributos_persistibles, simbolo)
      obtener_valor_has_many(valor, clase)
    elsif es_tipo_primitivo(clase)
      valor
    else
      valor.save!.id
    end
  end

  def obtener_valor_has_many(valor, clase)
    if  es_tipo_primitivo(clase)
      valor.join(",")
    else
      valor.each{|instancia| instancia.save!.id}
      valor.map{|instancia| instancia.id}.join(",")
    end
  end

  #metodo extraido porque lo usa la clase y las instancias
  def settear_atributos
    atr_persistibles_sin_has_many(atributos_persistibles).each do |simbolo, clase|
      if self.class.hash_atributos_persistidos(@id)[simbolo] == "" && clase != String
        #no debe hacer nada
      else
        settear_atributo(simbolo, clase)
      end
    end
    self
  end

  def settear_atributo(simbolo, clase)
    if es_atributo_has_many(atributos_persistibles, simbolo)
      settear_atributo_has_many(simbolo, clase)
    else
      if es_tipo_primitivo(clase)
        valor_a_settear = self.class.hash_atributos_persistidos(@id)[simbolo]
      else
        valor_a_settear = clase.find_by_id(self.class.hash_atributos_persistidos(@id)[simbolo])[0]
      end
      send(pasar_a_setter(simbolo), valor_a_settear)
    end
    self
  end

  def settear_atributo_has_many(simbolo, clase)
    send(pasar_a_setter(simbolo), [])
    if es_tipo_primitivo(clase)
      array_persistido_primitivo(simbolo, clase).each do |valor|
        send(pasar_a_setter(simbolo), send(simbolo).push(valor))
      end
    else
      array_persistido(simbolo).each do |id|
        send(pasar_a_setter(simbolo), send(simbolo).push(clase.find_by_id(id)[0]))
      end
    end
    self
  end

  def array_persistido(simbolo)
    self.class.hash_atributos_persistidos(@id)[simbolo].split(",")
  end

  def array_persistido_primitivo(simbolo, clase)
    if clase == Numeric
      array_persistido(simbolo).map{ |elem| elem.to_i }
    elsif clase == Boolean
      array_persistido(simbolo).map{ |elem| elem == "true" ? true : false }
    else
      array_persistido(simbolo)
    end
  end



  private
  attr_writer :id

  def es_tipo_primitivo(clase)
    clase == String || clase == Numeric || clase == Boolean
  end

  def pasar_a_setter(simbolo)
    (simbolo.to_s << "=").to_sym
  end

end