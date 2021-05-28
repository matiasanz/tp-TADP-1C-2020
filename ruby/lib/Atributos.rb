class Atributo

  def initialize(nombre, tipo)
    @nombre = nombre
    @tipo = tipo
  end

end

class AtributoSimple < Atributo

  def initialize(nombre, tipo)
    super(nombre, tipo)
  end

end

class AtributoMultiple < Atributo

  def initialize(nombre, tipo)
    super(nombre, tipo)
  end

end
