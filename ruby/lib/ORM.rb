require_relative 'InstanciaPersistible'
require_relative 'EntidadPersistible'
require_relative 'AdministradorDeTabla'

module ORM

  def self.included(modulo)
    entregar_dependecias(modulo)
  end

  def self.entregar_dependecias(modulo)
    modulo.extend(EntidadPersistible)
    modulo.module_eval do
      def self.included(modulo)
        ORM::entregar_dependecias(modulo)
        modulos_hijos.push(modulo)
      end
    end
    if modulo.is_a?(Class)
      modulo.include(InstanciaPersistible)
      modulo.extend(AdministradorDeTabla)
      modulo.class_eval do
        # esto inicializa los atributos que usan has_many con un array vacio []. Tambien inicializa los defaults
        # si el usuario define un contructor, solo tiene que escribir "inicializar_atributos" (si lo usa)
        # si no define contructor, funciona TOD0 bien
        def initialize
          inicializar_atributos
          super
        end

        def self.inherited(clase)
          modulos_hijos.push(clase)
        end
      end
    end
  end

end
