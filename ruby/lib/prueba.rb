class Prueba

  def materia
    :tadp
  end
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


# estaba en ORM
#modulo.incluye_orm = true
#
=begin
class Module

  attr_accessor :incluye_orm

  def modulos_hijos
    @modulos_hijos ||= []
  end

  def included(modulo)
    if @incluye_orm
      ORM::entregar_dependecias(modulo)
      modulos_hijos.push(modulo)
    end
  end

end

class Class
  def inherited(clase)
    if @incluye_orm
      clase.incluye_orm = true
      modulos_hijos.push(clase)
    end
  end
end
=end