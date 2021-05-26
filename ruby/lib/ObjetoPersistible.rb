require 'tadb'
require_relative 'Excepciones'
require_relative 'Util'

module ObjetoPersistible

  include Util

  attr_reader :id

  def atributos_persistibles
    self.class.atributos_persistibles
  end

  def save!
    raise SaveException.new unless atributos_persistibles
    self.class.inicializar_tabla unless self.class.tabla
    validate! # valida la instancia actual y las instancias asociadas
    # el "generar_hash_para_insertar" tambien cascadea el validate! a las instancias asociadas porque se realiza save! a cada una
    # osea, se realizan las validaciones 2 veces
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

  def validate!
    atributos_persistibles.each do |simbolo, clase|
      valor = send(simbolo)
      if valor.is_a?(Array)
        valor.each { |instancia| validar_todo(simbolo, clase, instancia) }
      else
        validar_todo(simbolo, clase, valor)
      end
    end
    self
  end

  def validar_todo(simbolo, clase, valor)
    validar_tipo(simbolo, clase, valor)
    validar_no_blank(simbolo, valor)
    validar_from(simbolo, clase, valor)
    validar_to(simbolo, clase, valor)
    validar_block_validate(simbolo, valor)
  end

  def validar_tipo(clave, clase, valor)
    if valor.nil?
      # no debe hacer nada
    elsif clase == Boolean
      raise TipoDeDatoException.new(self, clave, clase) unless valor.is_a?(Boolean)
    elsif clase == Numeric
      raise TipoDeDatoException.new(self, clave, clase) unless valor.is_a?(Numeric)
    elsif clase == String
      raise TipoDeDatoException.new(self, clave, clase) unless valor.is_a?(String)
    else
      if valor.is_a?(ObjetoPersistible)
        valor.validate!
      else
        raise TipoDeDatoException.new(self, clave, clase)
      end
    end
  end

  def validar_no_blank(simbolo, valor)
    if (valor.nil? || valor == "") && self.class.no_blank.include?(simbolo)
      raise NoBlankException.new(self, simbolo)
    end
  end

  def validar_from(simbolo, clase, valor)
    if clase == Numeric && self.class.from && self.class.from[simbolo] && self.class.from[simbolo] > valor
      raise FromException.new(self, simbolo, self.class.from[simbolo])
    end
  end

  def validar_to(simbolo, clase, valor)
    if clase == Numeric && self.class.to && self.class.to[simbolo] && self.class.to[simbolo] < valor
      raise ToException.new(self, simbolo, self.class.to[simbolo])
    end
  end

  def validar_block_validate(simbolo, valor)
    if self.class.validate && self.class.validate[simbolo] && !valor.instance_eval(&self.class.validate[simbolo])
      raise BlockValidateException.new(self, simbolo, self.class.validate[simbolo])
    end
  end

  #se usaria asi, en el constructor de la clase
  #def initialize
  #  inicializar_has_many
  #  super
  #end
  def inicializar_atributos_has_many
    if self.class.atributos_has_many
      self.class.atributos_has_many.each{ |simbolo| send(pasar_a_setter(simbolo), []) }
    end
    self
  end

  def generar_hash_para_insertar
    hash_para_insertar = {}
    atributos_persistibles.each do |simbolo, clase|
      valor = send(simbolo)
      hash_para_insertar[simbolo] = obtener_valor_a_insertar(simbolo, clase, valor) unless valor.nil?
    end
    hash_para_insertar[:id] = @id if @id
    hash_para_insertar
  end

  def obtener_valor_a_insertar(simbolo, clase, valor)
    if es_atributo_has_many(self.class.atributos_has_many, simbolo)
      obtener_valor_has_many(valor, clase)
    elsif es_tipo_primitivo(clase)
      valor
    else
      valor.save!.id
    end
  end

  def obtener_valor_has_many(valor, clase)
    if es_tipo_primitivo(clase)
      valor.join(",")
    else
      valor.map{|instancia| instancia.save!.id}.join(",")
    end
  end

  #metodo extraido porque lo usa la clase y las instancias
  def settear_atributos
    atributos_persistibles.each do |simbolo, clase|
      settear_atributo(simbolo, clase) if self.class.hash_atributos_persistidos(@id).has_key?(simbolo)
    end
    self
  end

  def settear_atributo(simbolo, clase)
    if es_atributo_has_many(self.class.atributos_has_many, simbolo)
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