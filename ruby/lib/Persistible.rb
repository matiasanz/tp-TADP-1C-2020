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


  # define metodos y accesors para las clases persistibles (tambien funciona para modulos)
  def self.included(clase)
    clase.singleton_class.send(:attr_reader, :atributos_persistibles)
    clase.singleton_class.send(:attr_accessor, :tabla)

    clase.define_singleton_method(:has_one) do |tipo_atributo, named:|
      attr_accessor named
      @atributos_persistibles ||= {}
      @atributos_persistibles[named] = tipo_atributo
    end

    #para test
    clase.define_singleton_method(:tipo_de) do |nombre_atributo|
      return nil if @atributos_persistibles.nil?
      if @atributos_persistibles.has_key?(nombre_atributo)
        return @atributos_persistibles[nombre_atributo]
      end
      nil
    end

    clase.define_singleton_method(:all_instances) do
      return nil if @tabla.nil?
      @tabla.entries.map {|entrada| generar_instancia(entrada)}
    end

    # metodos auxiliares
    clase.define_singleton_method(:generar_instancia) do |entrada_de_tabla|
      instancia = self.new
      instancia.send(:id=, entrada_de_tabla[:id])
      instancia.settear_atributos
    end

  end

  #self.instance_eval do
  #  self.class.singleton_class.send(:attr_reader, :atributos_persistibles)
  #  self.class.singleton_class.send(:attr_accessor, :tabla)
  # end



  # metodos de instancias de clases persistibles
  def save!
    return nil if atributos_persistibles.nil?
    self.tabla= TADB::DB.table(self.class.name) if tabla.nil?
    forget! if @id  # lo actualiza si ya tenia un ID, para eso borro la entrada anterior
    # tener en cuenta que el ID cambia con cada save!()
    @id = tabla.insert(obtener_hash_para_insertar)
    self
  end

  def refresh!
    if @id == nil
      raise RefreshException.new(self)
    end
    settear_atributos
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

  #metodo extraido porque lo usa la clase y las instancias
  def settear_atributos
    atributos_symbolos = atributos_persistibles.keys
    atributos_symbolos.each do |simbolo|
      simbolo_setter = (simbolo.to_s << "=").to_sym
      self.send(simbolo_setter, atributos_persistidos[simbolo])
    end
    self
  end

  def atributos_persistidos
    entradas = tabla.entries
    entradas.each do |entrada|
      return entrada if entrada.has_value?(@id)
    end
    nil
  end

  private
  attr_writer :id

end