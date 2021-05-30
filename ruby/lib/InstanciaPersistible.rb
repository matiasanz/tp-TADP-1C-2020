require 'tadb'
require_relative 'Excepciones'
require_relative 'Util'
require_relative 'Atributos'

module InstanciaPersistible

  include Util

  attr_reader :id

  # validate! valida la instancia actual y las instancias asociadas si es un atributo complejo
  # el "generar_hash_para_insertar" tambien cascadea el validate! a las instancias asociadas porque se realiza save! a cada una
  # osea, se realizan las validaciones 2 veces (solo a los atributos complejos)
  def save!
    validate!
    hash = generar_hash_para_insertar
    forget! if @id
    @id = self.class.insertar_en_tabla(hash)
    self
  end

  def refresh!
    raise RefreshException.new(self.class.name) unless @id
    self.class.atributos_persistibles_totales.each do |atributo|
      atributo.settear(self) if self.class.hash_atributos_persistidos(@id).has_key?(atributo.nombre)
    end
    self
  end

  def forget!
    raise ForgetException.new(self.class.name) unless @id
    self.class.borrar_de_tabla(@id)
    @id = nil
    self
  end

  def validate!
    self.class.atributos_persistibles_totales.each do |atributo|
      atributo.validar_todo(send(atributo.nombre), self.class.name)
    end
    self
  end

  private

  attr_writer :id

  def generar_hash_para_insertar
    hash_para_insertar = {}
    self.class.atributos_persistibles_totales.each do |atributo|
      dato = send(atributo.nombre)
      unless dato.nil? || (dato.is_a?(Array) && dato[0].nil? && atributo.default.nil?)
        hash_para_insertar[atributo.nombre] = atributo.obtener_valor_para_insertar(dato, self.class.name)
      end
      hash_para_insertar[atributo.nombre] = atributo.default if dato.nil? && !atributo.default.nil?
    end
    hash_para_insertar[:id] = @id if @id
    hash_para_insertar
  end

  # en el constructor de la clase se usaria asi
  #def initialize
  #  inicializar_has_many
  #  super
  #end
  def inicializar_atributos
    self.class.atributos_persistibles_totales.each do |atributo|
      if atributo.is_a?(AtributoMultiple)
        send(pasar_a_setter(atributo.nombre), [])
        send(pasar_a_setter(atributo.nombre), send(atributo.nombre).push(atributo.default)) unless atributo.default.nil?
      end
      dato = send(atributo.nombre)
      send(pasar_a_setter(atributo.nombre), atributo.default) if dato.nil? && !atributo.default.nil?
    end
    self
  end

end