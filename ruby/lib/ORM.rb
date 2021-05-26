require_relative 'Boleean'
require_relative 'ObjetoPersistible'
require_relative 'ClasePersistible'

module ORM

  def self.included(modulo)
    entregar_dependecias(modulo)
  end

  def self.entregar_dependecias(modulo)
    modulo.extend(ClasePersistible)
    modulo.incluye_orm = true

    if modulo.is_a?(Class)
      modulo.include(ObjetoPersistible) #asi no lo incluyen los modulos

      # esto inicializa los atributos que usan has_many con un array vacio []
      # si el usuario define un contructor, solo tiene que escribir inicializar_has_many (si lo usa)
      # si no define contructor, funciona TOD0 bien
      modulo.class_eval do
        def initialize
          inicializar_atributos_has_many
          super
        end
      end
    end
  end

end

class Module

  def incluye_orm=(valor)
    @incluye_orm = valor
  end

  def incluye_orm?
    @incluye_orm ||= false
  end

  def modulos_hijos
    @modulos_hijos ||= []
  end

  def included(modulo)
    if @incluye_orm
      ORM::entregar_dependecias(modulo)
      modulos_hijos
      @modulos_hijos.push(modulo)
    end
  end

end

class Class
  def inherited(clase)
    if @incluye_orm
      modulos_hijos
      @modulos_hijos.push(clase)
      clase.incluye_orm = true
    end
  end
end