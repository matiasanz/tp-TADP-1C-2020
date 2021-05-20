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

  def insertar(hash_a_insertar)  ## deberia ser private TODO
    @tabla = TADB::DB.table(self.name) if @tabla.nil?
    @tabla.insert(hash_a_insertar)
  end

  def obtener_atributos_persistidos(id:)
    entradas = @tabla.entries
    entradas.each do |entrada|
      return entrada if entrada.has_value?(id)
    end
  end

  ## cosas de instancias de clases
  def save!
    return nil if self.class.atributos_persistibles.nil?
    @id = self.class.insertar(obtener_hash_para_insertar(self))
  end

  def id
    @id
  end

  def refresh!
    if self.id == nil
      raise RefreshException.new(self)
    end
    atributos = self.class.atributos_persistibles.keys
    hash_con_atributos_persistidos = self.class.obtener_atributos_persistidos(id: self.id)
    atributos.each do |simbolo|
      setters = simbolo.to_s << "="
      self.send(setters.to_sym, hash_con_atributos_persistidos[simbolo])
    end

  end

  #private
    def obtener_hash_para_insertar(objeto)
      hash_para_insertar = {}
      self.class.atributos_persistibles.each do |key, _|
        if objeto.send(key) == nil
          hash_para_insertar[key] = objeto.send(key).to_s
        else
          hash_para_insertar[key] = objeto.send(key)
        end
      end
      hash_para_insertar
    end

end