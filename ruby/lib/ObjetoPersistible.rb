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

=begin
  # define metodos y accesors para las clases persistibles
  def self.included(clase)
    clase.singleton_class.send(:attr_reader, :atributos_persistibles)
    clase.singleton_class.send(:attr_accessor, :tabla)
  end
=end

  def save!
    raise SaveException.new(self) unless atributos_persistibles
    self.class.inicializar_tabla unless tabla
    hash = generar_hash_para_insertar
    forget! if @id
    @id = tabla.insert(hash)
    self
  end

  def refresh!
    raise RefreshException.new(self) unless @id
    settear_atributos
    self
  end

  def forget!
    raise ForgetException.new(self) unless @id
    tabla.delete(@id)
    @id = nil
    self
  end

  #se usaria asi
  #def initialize
  #  inicializar_has_many
  #  super
  #end
  def inicializar_has_many
    if atributos_persistibles[:has_many_attr]
      atributos_persistibles[:has_many_attr].each do |simbolo|
        simbolo_setter = (simbolo.to_s << "=").to_sym #logica repetida TODO
        send(simbolo_setter, [])
      end
    end
  end

  def generar_hash_para_insertar  #deberia ser private? TODO
    hash_para_insertar = {}
    has_many_attr = atributos_persistibles[:has_many_attr]
    atributos_persistibles.each do |key, value|       #logica repedida... TODO
      if key == :has_many_attr
        hash_para_insertar[key] = value.to_s  #persisto las relaciones has_many para usar despues
      elsif send(key) == nil                  #mejor deberia crear una tabla por relacion TODO
        hash_para_insertar[key] = ""
      elsif value != String && value != Numeric && value != Boolean && has_many_attr != nil && has_many_attr.include?(key)
        send(key).each{|instancia| instancia.save!.id}
        hash_para_insertar[key] = send(key).map{|instancia| instancia.id}.join(",")
      elsif (value == String || value == Numeric || value == Boolean) && has_many_attr != nil && has_many_attr.include?(key)
        hash_para_insertar[key] = send(key).join(",")    #esto es provisorio, es hasta que tenga una tabla por relacion TODO
      elsif value != String && value != Numeric && value != Boolean
        hash_para_insertar[key] = send(key).save!.id
      else
        hash_para_insertar[key] = send(key)
      end
    end
    hash_para_insertar[:id] = @id
    hash_para_insertar
  end

  #metodo extraido porque lo usa la clase y las instancias
  def settear_atributos
    has_many_attr = atributos_persistibles[:has_many_attr]
    atributos_persistibles_temp = atributos_persistibles.clone
    atributos_persistibles_temp.delete(:has_many_attr)
    atributos_persistibles_temp.each do |simbolo, clase|
      simbolo_setter = (simbolo.to_s << "=").to_sym
      if clase != String && clase != Numeric && clase != Boolean && has_many_attr != nil && has_many_attr.include?(simbolo)
        send(simbolo_setter, [])
        hash_atributos_persistidos[simbolo].split(",").each do
          |id| self.send(simbolo_setter, send(simbolo).push(clase.find_by_id(id)[0]))
        end
      elsif (clase == String || clase == Numeric || clase == Boolean) && has_many_attr != nil && has_many_attr.include?(simbolo)
        array = hash_atributos_persistidos[simbolo].split(",")
        if clase == Numeric
          array = array.map{ |elem| elem.to_i }
        elsif clase == Boolean
          array = array.map { |elem| elem == "true" ? true : false }
        end
        send(simbolo_setter, [])
        array.each do
        |valor| self.send(simbolo_setter, send(simbolo).push(valor))   #esto es provisorio, es hasta que tenga una tabla por relacion TODO
        end
      elsif clase != String && clase != Numeric && clase != Boolean  #logica repetida con obtener_hash_para_insertar TODO
        self.send(simbolo_setter, clase.find_by_id(hash_atributos_persistidos[simbolo])[0])
      else
        self.send(simbolo_setter, hash_atributos_persistidos[simbolo])
      end
    end
    self
  end

  def hash_atributos_persistidos
    entradas = tabla.entries
    entradas.each { |entrada| return entrada if entrada.has_value?(@id) }
    nil
  end

  private
  attr_writer :id

end