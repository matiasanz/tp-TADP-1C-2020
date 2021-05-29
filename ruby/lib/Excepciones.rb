
class RefreshException < StandardError
  def initialize(nombre_clase)
    super("No es posible ejecutar refresh!(), el objeto de la clase " + nombre_clase + " no posee id")
  end
end

class ForgetException < StandardError
  def initialize(nombre_clase)
    super("No es posible ejecutar forget!(), el objeto de la clase " + nombre_clase + " no posee id")
  end
end

class TipoDeDatoException < StandardError
  def initialize(nombre_clase, atributo, tipo)
    super("El atributo \"" + atributo.to_s + "\" de la clase \"" + nombre_clase +
              "\" no corresponde con el tipo declarado. Debe ingresar :" + tipo.name)
  end
end

class NoBlankException < StandardError
  def initialize(nombre_clase, atributo)
    super("El atributo \"" + atributo.to_s + "\" de la clase \"" + nombre_clase + "\" no esta inicializado.")
  end
end

class FromException < StandardError
  def initialize(nombre_clase, atributo, from)
    super("El atributo \"" + atributo.to_s + "\" de la clase \"" + nombre_clase + "\" debe ser mayor que " + from.to_s)
  end
end

class ToException < StandardError
  def initialize(nombre_clase, atributo, to)
    super("El atributo \"" + atributo.to_s + "\" de la clase \"" + nombre_clase + "\" debe ser menor que " + to.to_s)
  end
end

class BlockValidateException < StandardError
  def initialize(nombre_clase, atributo, proc)
    super("El atributo \"" + atributo.to_s + "\" de la clase \"" + nombre_clase + "\" no cumple con: #{proc}")
  end
end