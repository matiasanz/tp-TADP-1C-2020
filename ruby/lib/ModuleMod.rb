require_relative 'Persistible'
require_relative 'Boleean'

class Module

  def atributos_persistibles
    @atributos_persistibles
  end

  def has_one(tipo_atributo, named:)
    attr_accessor named
    @atributos_persistibles = {} if @atributos_persistibles.nil?
    @atributos_persistibles[named] = tipo_atributo
  end

end
