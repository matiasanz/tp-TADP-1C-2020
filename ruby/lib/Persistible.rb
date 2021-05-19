require 'tadb'

class Object

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

  def atributos_persistibles
    @atributos_persistibles
  end

  def insertar
    @tabla = TADB::DB.table("#{self.name}") if @tabla.nil?
    @tabla.insert(obtener_hash_para_insertar)
  end

  def table
    @tabla
  end

  ## cosas de instancias de clases
  def save!
    return nil if self.class.atributos_persistibles.nil?
    @id = self.class.insertar
  end

  def id
    @id
  end

  #private
    def obtener_hash_para_insertar  ###TODO
      hash_para_insertar = {}
      @atributos_persistibles.each do |key, value|
        hash_para_insertar[key] = value.to_s
      end
      hash_para_insertar
    end

end