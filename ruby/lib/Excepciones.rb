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
  def initialize(objeto)
    super("No es posible ejecutar save!(), falta utilizar has_one o has_many")
  end
end