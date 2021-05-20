require 'tadb'
require_relative 'Excepciones'

class Object

  def atributos_persistibles
    @atributos_persistibles
  end

  def has_one(tipo_atributo, named:)
    @atributos_persistibles = {} if @atributos_persistibles.nil?
    @atributos_persistibles[named] = tipo_atributo
  end

  #para test
  def tipo_de(nombre_atributo)
    return nil if @atributos_persistibles.nil?
    if @atributos_persistibles.has_key?(nombre_atributo)
      return @atributos_persistibles[nombre_atributo]
    end
    nil
  end

  #para test
  def tiene_id_en_tabla?(id:)
    entradas = @tabla.entries
    resultado = false
    entradas.each do |entrada|
      resultado = true if entrada.has_value?(id)
    end
    resultado
  end

  def insertar(hash_a_insertar)
    @tabla = TADB::DB.table(name) if @tabla.nil?
    @tabla.insert(hash_a_insertar)
  end

  def atributos_persistidos_de(id:)
    entradas = @tabla.entries
    entradas.each do |entrada|
      return entrada if entrada.has_value?(id)
    end
  end

  def borrar_de_tabla(id)
    @tabla.delete(id)
  end

  ## cosas de instancias de clases
  def save!
    return nil if self.class.atributos_persistibles.nil?
    @id = self.class.insertar(obtener_hash_para_insertar)
  end

  def id
    @id
  end

  def refresh!
    if @id == nil
      raise RefreshException.new(self)
    end
    atributos = self.class.atributos_persistibles.keys
    hash_con_atributos_persistidos = self.class.atributos_persistidos_de(id: @id)
    atributos.each do |simbolo|
      setters = simbolo.to_s << "="
      self.send(setters.to_sym, hash_con_atributos_persistidos[simbolo])
    end
  end

  def forget!
    if @id == nil
      raise ForgetException.new(self)
    end
    self.class.borrar_de_tabla(@id)
    @id = nil
  end

  def obtener_hash_para_insertar  #deberia ser private TODO
    hash_para_insertar = {}
    self.class.atributos_persistibles.keys.each do |key|
      if send(key) == nil
        hash_para_insertar[key] = send(key).to_s
      else
        hash_para_insertar[key] = send(key)
      end
    end
    hash_para_insertar
  end

end