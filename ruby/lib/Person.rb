require_relative 'ORM'

class Person

  include ORM

  attr_accessor :some_other_non_persistible_attribute

  has_one String, named: :first_name
  has_one String, named: :last_name
  has_one Numeric, named: :age
  has_one Boolean, named: :admin

end

#estaba en "ObjetoPersistible"
=begin
  # define metodos y accesors para las clases persistibles
  def self.included(clase)
    clase.singleton_class.send(:attr_reader, :atributos_persistibles)
    clase.singleton_class.send(:attr_accessor, :tabla)
  end
=end

# estaba en "ClasePersistible"
#def definir_getter(named)
#  send(:define_method, named) do
#    obj.instance_variable_set("@#{named.to_s}".to_sym, [])
#  end
#end


# estaba en "ORM" <<<<<<<<<<<<<
#modulo.class_eval do
#  def initialize
#    inicializar_atributos_has_many
#    super
#  end
#end

# Hace lo mismo que arriba
#modulo.send(:define_method, :initialize) do
#  inicializar_has_many
#  super()
#end

# Hace lo mismo que arriba
#modulo.define_singleton_method(:initialize) do
#  inicializar_has_many
#  super()
#end