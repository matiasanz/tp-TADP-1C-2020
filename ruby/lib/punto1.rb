class Person
  has_one String, named: :first_name
  has_one String, named: :last_name
  has_one Numeric, named: :age
  has_one Boolean, named: :admin

  attr_accessor :some_other_non_persistible_attribute

end


module Persistible

  def initialize
    @hash = {}
  end

  def has_one(type: , named:)
    @hash = @hash.merge(named => type)
  end
end


class Boolean < Comparable
  #??

  def initialize valor:
    if valor.is_a?(Comparable)
      @valor = valor
    else
      raise "No es un Booleano"
    end
  end

  def verdadero?
    @valor == true
  end

  def falso?
    @valor == false
  end
end


=begin
Los atributos persistibles deben poder leerse y setearse de forma normal; no es necesario (todavía)
realizar ninguna validación sobre su tipo o contenido.

  p = Person.new
p.first_name = "raul"   # Esto funciona
p.last_name = 8         # Esto también. Por ahora…
p.last_name             # Retorna 8
=end



