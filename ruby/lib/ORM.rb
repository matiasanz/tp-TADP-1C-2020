require_relative 'InstanciaPersistible'
require_relative 'EntidadPersistible'
require_relative 'AdministradorDeTabla'

module ORM

  def self.included(modulo)
    entregar_dependecias(modulo)
  end

  def self.entregar_dependecias(modulo)
    modulo.extend(EntidadPersistible)
    modulo.incluye_orm = true
    if modulo.is_a?(Class)
      modulo.include(InstanciaPersistible)
      modulo.extend(AdministradorDeTabla)
      # esto inicializa los atributos que usan has_many con un array vacio []. Tambien inicializa los defaults
      # si el usuario define un contructor, solo tiene que escribir "inicializar_atributos" (si lo usa)
      # si no define contructor, funciona TOD0 bien
      modulo.class_eval do
        def initialize
          inicializar_atributos
          super
        end
      end
    end
  end

end

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