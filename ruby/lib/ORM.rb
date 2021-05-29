require_relative 'InstanciaPersistible'
require_relative 'EntidadPersistible'
require_relative 'AdministradorDeTabla'

module ORM

  def self.included(modulo)
    entregar_dependecias(modulo)
  end

  def self.entregar_dependecias(modulo)
    dependencias_modulos_y_clases(modulo)
    dependencias_de_clases(modulo) if modulo.is_a?(Class)
  end

  private

  def self.dependencias_modulos_y_clases(modulo)
    modulo.extend(EntidadPersistible)
    modulo.module_eval do
      def self.included(otro_modulo)
        ORM::entregar_dependecias(otro_modulo)
        modulos_hijos.push(otro_modulo)
      end
    end
  end

  def self.dependencias_de_clases(clase)
    clase.include(InstanciaPersistible)
    clase.extend(AdministradorDeTabla)
    clase.class_eval do
      # esto inicializa los atributos que usan has_many con un array vacio []. Tambien inicializa los defaults
      # si el usuario define un contructor, solo tiene que escribir "inicializar_atributos" (si lo usa)
      # si no define contructor, funciona TOD0 bien
      def initialize
        inicializar_atributos
        super
      end

      def self.inherited(otra_clase)
        modulos_hijos.push(otra_clase)
      end

    end
  end

end
