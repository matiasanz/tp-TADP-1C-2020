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
    raise SaveException.new unless atributos_persistibles
    self.class.inicializar_tabla unless self.class.tabla
    validate!                             # valida la instancia actual y las instancias asociadas
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
    atr_persistibles_sin_has_many(atributos_persistibles).each do |simbolo, clase|
      valor = send(simbolo)
      raise ValidateException.new(self, simbolo, clase) unless valor.class == NilClass || corresponde_tipo(simbolo, valor)
    end
    self
  end

  def corresponde_tipo(clave, valor)
    if es_atributo_has_many(atributos_persistibles, clave)
      array = valor # es para darle un poquito mas de expresividad. Si entra en este if, el valor es un array
      if atributos_persistibles[clave] == Boolean
        todos_son(array, Boolean)
      elsif atributos_persistibles[clave] == Numeric
        todos_son(array, Numeric)
      elsif atributos_persistibles[clave] == String
        todos_son(array, String)
      else
        if todos_son(array, ObjetoPersistible)
          array.each { |elem| elem.validate! }
        else
          raise ValidateException.new(self, clave, atributos_persistibles[clave])
        end
      end
    else
      if atributos_persistibles[clave] == Boolean
        valor.is_a?(Boolean)
      elsif atributos_persistibles[clave] == Numeric
        valor.is_a?(Numeric)
      elsif atributos_persistibles[clave] == String
        valor.is_a?(String)
      else
        if valor.is_a?(ObjetoPersistible)
          valor.validate!
        else
          raise ValidateException.new(self, clave, atributos_persistibles[clave])
        end
      end
    end
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
      valor = send(simbolo)
      hash_para_insertar[simbolo] = obtener_valor_a_insertar(simbolo, clase, valor) if valor.class != NilClass
    end
    hash_para_insertar[:id] = @id if @id
    hash_para_insertar
  end

  def obtener_valor_a_insertar(simbolo, clase, valor)
    if es_atributo_has_many(atributos_persistibles, simbolo)
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
    atr_persistibles_sin_has_many(atributos_persistibles).each do |simbolo, clase|
      settear_atributo(simbolo, clase) if self.class.hash_atributos_persistidos(@id).has_key?(simbolo)
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

  def todos_son(valor, tipo)
    valor.all? { |elem| elem.is_a?(tipo) }
  end

end