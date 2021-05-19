require 'tadb'

class Object

  def has_one(tipo_atributo, named:)
    @atributos_persistibles = [] if @atributos_persistibles.nil?

    posicion_array = -1
    @atributos_persistibles.each_with_index do |hash, posicion|
      posicion_array = posicion if hash.has_value?(named)
    end

    if posicion_array == -1
      @atributos_persistibles.push({ :tipo => tipo_atributo, :valor => named })
    else
      @atributos_persistibles[posicion_array] = { :tipo => tipo_atributo, :valor => named }
    end
  end

  #para test
  def tipo_de(nombre_atributo)
    return nil if @atributos_persistibles.nil?

    posicion_array = -1
    @atributos_persistibles.each_with_index do |hash, posicion|
      posicion_array = posicion if hash.has_value?(nombre_atributo)
    end

    posicion_array == -1 ? nil : @atributos_persistibles[posicion_array][:tipo]
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

  def att
    @atributos_persistibles
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
    def obtener_hash_para_insertar
      hash_para_insertar = {}
      @atributos_persistibles.each do |hash|
        hash_para_insertar[hash[:valor]] = hash[:valor].to_s
      end
      hash_para_insertar
    end

end