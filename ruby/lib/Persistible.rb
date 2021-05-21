require 'tadb'
require_relative 'Excepciones'

module ObjetoPersistible

  attr_reader :id

  def atributos_persistibles
    self.class.atributos_persistibles
  end

  def tabla
    self.class.tabla
  end

  def tabla=(tabla)
    self.class.tabla = tabla
  end



  # metodos de instancias de clases persistibles
  def save!
    return nil if atributos_persistibles.nil?
    self.tabla= TADB::DB.table(self.class.name) if tabla.nil?
    @id = tabla.insert(obtener_hash_para_insertar)
    self
  end

  def refresh!
    if @id == nil
      raise RefreshException.new(self)
    end
    atributos_symbolos = atributos_persistibles.keys
    hash_con_atributos_persistidos = atributos_persistidos
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
    tabla.delete(@id)
    @id = nil
    self
  end

  def obtener_hash_para_insertar  #deberia ser private TODO
    hash_para_insertar = {}
    atributos_persistibles.keys.each do |key|
      if send(key) == nil
        hash_para_insertar[key] = ""
      else
        hash_para_insertar[key] = send(key)
      end
    end
    hash_para_insertar
  end

  def atributos_persistidos
    entradas = tabla.entries
    entradas.each do |entrada|
      return entrada if entrada.has_value?(id)
    end
    nil
  end

end