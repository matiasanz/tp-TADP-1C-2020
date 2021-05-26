class RefreshException < StandardError
  def initialize(objeto)
    super("No es posible ejecutar refresh!(), el objeto de la clase " + objeto.class.name + " no posee id")
  end
end

class ForgetException < StandardError
  def initialize(objeto)
    super("No es posible ejecutar forget!(), el objeto de la clase " + objeto.class.name + " no posee id")
  end
end

class SaveException < StandardError
  def initialize
    super("No es posible ejecutar save!(), falta utilizar has_one o has_many")
  end
end

class TipoDeDatoException < StandardError
  def initialize(objeto, atributo, tipo)
    super("El atributo \"" + atributo.to_s + "\" de la clase \"" + objeto.class.name +
              "\" no corresponde con el tipo declarado. Debe ingresar :" + tipo.name)
  end
end

class NoBlankException < StandardError
  def initialize(objeto, atributo)
    super("El atributo \"" + atributo.to_s + "\" de la clase \"" + objeto.class.name + "\" no esta inicializado.")
  end
end

class FromException < StandardError
  def initialize(objeto, atributo, from)
    super("El atributo \"" + atributo.to_s + "\" de la clase \"" + objeto.class.name + "\" debe ser mayor que " + from.to_s)
  end
end

class ToException < StandardError
  def initialize(objeto, atributo, to)
    super("El atributo \"" + atributo.to_s + "\" de la clase \"" + objeto.class.name + "\" debe ser menor que " + to.to_s)
  end
end

class BlockValidateException < StandardError
  def initialize(objeto, atributo, proc)
    super("El atributo \"" + atributo.to_s + "\" de la clase \"" + objeto.class.name + "\" no cumple con: #{proc}")
  end
end