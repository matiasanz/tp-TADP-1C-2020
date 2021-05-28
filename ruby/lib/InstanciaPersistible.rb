require 'tadb'
require_relative 'Excepciones'
require_relative 'Util'
require_relative 'Atributos'

module InstanciaPersistible

  include Util

  attr_reader :id

  # en el constructor de la clase se usaria asi
  #def initialize
  #  inicializar_has_many
  #  super
  #end
  def inicializar_atributos
    self.class.atributos_persistibles_totales.each do |atributo|
      send(pasar_a_setter(atributo.nombre), []) if atributo.is_a?(AtributoMultiple)
    end
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
    self.class.atributos_persistibles_totales.each do |atributo|
      atributo.settear(self) if self.class.hash_atributos_persistidos(@id).has_key?(atributo.nombre)
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
    self.class.atributos_persistibles_totales.each do |atributo|
      valor = send(atributo.nombre)
      if valor.is_a?(Array)
        valor.each { |instancia| self.class.validar_todo(atributo, instancia) }
      else
        self.class.validar_todo(atributo, valor)
      end
    end
    self
  end

  def generar_hash_para_insertar
    hash_para_insertar = {}
    self.class.atributos_persistibles_totales.each do |atributo|
      valor = send(atributo.nombre)
      hash_para_insertar[atributo.nombre] = atributo.obtener_valor_para_insertar(valor) unless valor.nil?
      hash_para_insertar[atributo.nombre] = self.class.default[atributo.nombre] if self.class.tiene_valor_default(atributo, valor)
    end
    hash_para_insertar[:id] = @id if @id
    hash_para_insertar
  end



  private
  attr_writer :id

end