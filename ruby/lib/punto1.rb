class Person

  has_one String, named: :first_name
  has_one String, named: :last_name
  has_one Numeric, named: :age
  has_one Boolean, named: :admin

  def has_one(tipo, descripcion)
    @tipo = tipo
    @descripcion = descripcion
  end
end



class Module

  def initialize()
    @atributos_persistibles = {  }
  end

  attr_accessor :tipo_de_dato, :named

  def has_one(tipo_de_dato, nombre)
    self.instance_eval "@#{attr_name} = Array.new"
    persistable_attributes[nombre] = tipo_de_dato

  end

  def Boolean(num)
    if num == 1 then
      true
    else
      false
    end
  end
end



####
#
#
#
#





def has_one(type, constraints)
  unless [String, Numeric, Boolean].include?(type) ||
    type.is_a?(ORM::PersistableClass)
    raise "Error: un atributo debe ser de una clase persistible"
  end

  # Extraer la clave :named porque va a ser la clave del hash de atributos.
  attr_name = constraints.delete(:named)

  unless self.is_a?(ORM::PersistableClass) then
    # Incluir el mixin que brinda las operaciones save, refresh y forget.
    include ORM::PersistableObject

    # Extender la clase agregando el metodo all_instances().
    extend ORM::PersistableClass

    # Definir id, id= y find_by_id con una llamada recursiva.
    has_one String, named: :id
  end

  attribute_map = AttributeMap.new(type, constraints)

  # Getter para el atributo que devuelve un valor
  #   por default si este no esta definido.
  self.send(:define_method, attr_name) do
    if instance_variables.include?("@#{attr_name}".to_sym)
      self.instance_eval "@#{attr_name}"
    elsif attribute_map.complex?
      self.instance_eval "@#{attr_name} = Array.new"
    else
      attribute_map.default_value
    end
  end

  # Setter para el atributo.
  attr_accessor attr_name

  # Define un metodo find_by_<atributo> que recibe un valor
  self.define_singleton_method("find_by_#{attr_name}") do |value|
    all_instances.find_all do |instance|
      instance.send(attr_name) == value
    end
  end

  # Guarda attribute_map en la coleccion. La clase Hash a su vez
  #   asegura que cada clave (nombre de atributo) sea unica.
  persistable_attributes[attr_name] = attribute_map
end
