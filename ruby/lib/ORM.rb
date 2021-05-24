require_relative 'Boleean'
require_relative 'ObjetoPersistible'
require_relative 'ClasePersistible'

module ORM

  include ObjetoPersistible

  def self.included(clase)
    clase.extend(ClasePersistible)

    # esto inicializa los atributos que usan has_many con un array vacio []
    # si el usuario define un contructor, solo tiene que escribir inicializar_has_many (si lo usa)
    # si no define contructor, funciona TOD0 bien
    clase.class_eval do
      def initialize
        inicializar_atributos_has_many
        super
      end
    end

    # Hace lo mismo que arriba
    #clase.send(:define_method, :initialize) do
    #  inicializar_has_many
    #  super()
    #end

    # Hace lo mismo que arriba
    #clase.define_singleton_method(:initialize) do
    #  inicializar_has_many
    #  super()
    #end

  end

end
