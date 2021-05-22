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

    clase.define_singleton_method(:method_missing) do |mensaje, *args, &bloque|
      if clase.respond_to?(mensaje, false)
        #naturalmente falla si el metodo tiene aridad != 0, porque asi esta definido en respond_to_missing?
        mensaje_a_enviar = mensaje.to_s.gsub("find_by_", "").to_sym
        all_instances.select {|instancia| instancia.send(mensaje_a_enviar) == args[0]}
      else
        super(mensaje, *args, bloque)
      end
    end

    clase.define_singleton_method(:respond_to_missing?) do |mensaje, include_all_private_methods = false|
      instancia = clase.new
      mensaje_a_instancia = mensaje.to_s.gsub("find_by_", "").to_sym    #mini logica repetida en :method_missing arriba TODO. podria se un util
      if instancia.respond_to?(mensaje_a_instancia, false)
        metodo = instancia.method(mensaje_a_instancia)
        return metodo.arity == 0 || super(mensaje, *include_all_private_methods)
      else
        super(mensaje, *include_all_private_methods)
      end
    end

    # metodos auxiliares
    clase.define_singleton_method(:generar_instancia) do |entrada_de_tabla|
      instancia = clase.new
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
    if @id
      id_temporal = @id
      forget!   # lo actualiza si ya tenia un ID, para eso borro la entrada anterior
      @id = tabla.insert(obtener_hash_para_insertar(id_temporal))
    else
      @id = tabla.insert(obtener_hash_para_insertar(@id))
    end
    self
  end

  def refresh!
    raise RefreshException.new(self) if @id == nil
    settear_atributos
    self
  end

  def forget!
    raise ForgetException.new(self) if @id == nil
    tabla.delete(@id)
    @id = nil
    self
  end

  def obtener_hash_para_insertar(id)  #deberia ser private? TODO
    hash_para_insertar = {}
    atributos_persistibles.each do |key, value|
      if send(key) == nil
        hash_para_insertar[key] = ""
      elsif value != String && value != Numeric && value != Boolean
        hash_para_insertar[key] = send(key).save!.id
      else
        hash_para_insertar[key] = send(key)
      end
    end
    hash_para_insertar[:id] = id
    hash_para_insertar
  end

  #metodo extraido porque lo usa la clase y las instancias
  def settear_atributos
    atributos_persistibles.each do |simbolo, value|
      simbolo_setter = (simbolo.to_s << "=").to_sym
      if value != String && value != Numeric && value != Boolean  #logica repetida con obtener_hash_para_insertar TODO
        self.send(simbolo_setter, value.find_by_id(atributos_persistidos[simbolo])[0])
      else
        self.send(simbolo_setter, atributos_persistidos[simbolo])
      end
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