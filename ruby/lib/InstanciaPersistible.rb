require 'tadb'
require_relative 'Excepciones'
require_relative 'Util'

module InstanciaPersistible

  include Util

  attr_reader :id

  # en el constructor de la clase se usaria asi
  #def initialize
  #  inicializar_has_many
  #  super
  #end
  def inicializar_atributos
    self.class.atributos_has_many.each{ |simbolo| send(pasar_a_setter(simbolo), []) }
    self.class.default.each{ |simbolo, valor_default| send(pasar_a_setter(simbolo), valor_default) }
    self
  end

  def save!
    self.class.inicializar_tabla unless self.class.tiene_tabla
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
    self.class.atributos_persistibles.each do |simbolo, clase|
      settear_atributo(simbolo, clase) if self.class.hash_atributos_persistidos(@id).has_key?(simbolo)
    end
    self
  end

  def forget!
    raise ForgetException.new(self) unless @id
    self.class.borrar_de_tabla(@id)
    @id = nil
    self
  end

  def validate!
    self.class.atributos_persistibles.each do |simbolo, _|
      valor = send(simbolo)
      if valor.is_a?(Array)
        valor.each { |instancia| self.class.validar_todo(simbolo, instancia) }
      else
        self.class.validar_todo(simbolo, valor)
      end
    end
    self
  end

  def generar_hash_para_insertar
    hash_para_insertar = {}
    self.class.atributos_persistibles.each do |simbolo, _|
      valor = send(simbolo)
      hash_para_insertar[simbolo] = self.class.obtener_valor_a_insertar(simbolo, valor) unless valor.nil?
      hash_para_insertar[simbolo] = self.class.default[simbolo] if self.class.tiene_valor_default(simbolo, valor)
    end
    hash_para_insertar[:id] = @id if @id
    hash_para_insertar
  end

  def settear_atributo(simbolo, clase)
    if self.class.atributos_has_many.include?(simbolo)
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

  def array_persistido_primitivo(simbolo, clase)
    if clase == Numeric
      array_persistido(simbolo).map{ |elem| elem.to_i }
    elsif clase == Boolean
      array_persistido(simbolo).map{ |elem| elem == "true" ? true : false }
    else
      array_persistido(simbolo)
    end
  end

  def array_persistido(simbolo)
    self.class.hash_atributos_persistidos(@id)[simbolo].split(",")
  end



  private
  attr_writer :id

end