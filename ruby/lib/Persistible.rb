require 'tadb'
require_relative 'Excepciones'

#module ObjetoPersistible

class Object

  #def atributos_persistibles
  #  @atributos_persistibles
  #end


  #class << self

=begin
    def has_one(tipo_atributo, named:)
      attr_accessor named
      @atributos_persistibles = {} if @atributos_persistibles.nil?
      @atributos_persistibles[named] = tipo_atributo
    end
=end

    #para test
    def tipo_de(nombre_atributo)
      return nil if @atributos_persistibles.nil?
      if @atributos_persistibles.has_key?(nombre_atributo)
        return @atributos_persistibles[nombre_atributo]
      end
      nil
    end

    def insertar(hash_a_insertar)
      @tabla = TADB::DB.table(name) if @tabla.nil?
      @tabla.insert(hash_a_insertar)  #devuelve el id
    end

    def atributos_persistidos_de(id:)
      entradas = @tabla.entries
      entradas.each do |entrada|
        return entrada if entrada.has_value?(id)
      end
      nil
    end

    def borrar_de_tabla(id)
      @tabla.delete(id)
    end

  #end

  #module_function :tipo_de, :tiene_id_en_tabla?, :insertar, :atributos_persistidos_de, :borrar_de_tabla

  ## cosas de instancias de clases
  def save!
    return nil if self.class.atributos_persistibles.nil?
    @id = self.class.insertar(obtener_hash_para_insertar)
    self
  end

  def id
    @id
  end

  def refresh!
    if @id == nil
      raise RefreshException.new(self)
    end
    atributos_symbolos = self.class.atributos_persistibles.keys
    hash_con_atributos_persistidos = self.class.atributos_persistidos_de(id: @id)
    atributos_symbolos.each do |simbolo|
      simbolo_setter = (simbolo.to_s << "=").to_sym
      self.send(simbolo_setter, hash_con_atributos_persistidos[simbolo])
    end
    self
  end

  def forget!
    if @id == nil
      raise ForgetException.new(self)
    end
    self.class.borrar_de_tabla(@id)
    @id = nil
    self
  end

  def obtener_hash_para_insertar  #deberia ser private TODO
    hash_para_insertar = {}
    self.class.atributos_persistibles.keys.each do |key|
      if send(key) == nil
        hash_para_insertar[key] = ""
      else
        hash_para_insertar[key] = send(key)
      end
    end
    hash_para_insertar
  end

end