require_relative 'Persistible'
require_relative 'Boleean'

class Module

  #attr_reader :atributos_persistibles
  #attr_accessor :tabla

  #def has_one(tipo_atributo, named:)
  #  attr_accessor named
  #  @atributos_persistibles ||= {}
  #  @atributos_persistibles[named] = tipo_atributo
  #end

  #para test
  #def tipo_de(nombre_atributo)
  #  return nil if @atributos_persistibles.nil?
  #  if @atributos_persistibles.has_key?(nombre_atributo)
  #    return @atributos_persistibles[nombre_atributo]
  #  end
  #  nil
  #end

end
