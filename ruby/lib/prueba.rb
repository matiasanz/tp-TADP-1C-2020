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


# estaba en AdministradorDeTabla
=begin
def analizar_ancestros
  ancestros = []
  ancestors.each do |ancestro|
    break if ancestro == ORM
    ancestros.push(ancestro) if ancestro.is_a?(EntidadPersistible)
  end
  ancestros.delete_at(0)
  agregar_atributos_de_ancestros(ancestros) if ancestros.size > 0
  self
end

def agregar_atributos_de_ancestros(ancestros)
  ancestros.reverse!
  atr_persistibles_original = atributos_persistibles.clone
  atr_has_many_original = atributos_has_many.clone
  ancestros.each { |modulo| agregar_atributos_de(modulo.atributos_persistibles, modulo.atributos_has_many) }
  agregar_atributos_de(atr_persistibles_original, atr_has_many_original)
  atributos_has_many = self.atributos_has_many.uniq
  self
end

def agregar_atributos_de(hash_atributos, atributos_has_many)
  hash_atributos.each do |nombre, tipo|
    if atributos_has_many.include?(nombre)
      has_many(tipo, named: nombre)
    else
      has_one(tipo, named: nombre)
    end
  end
  self
end
=end