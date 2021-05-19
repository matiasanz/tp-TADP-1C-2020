require 'tadb'

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

  ## cosas de instancias de clases
  def save!
    return nil if self.class.atributos_persistibles.nil?
    @id = self.class.insertar(obtener_hash_para_insertar(self))
  end

  def id
    @id
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