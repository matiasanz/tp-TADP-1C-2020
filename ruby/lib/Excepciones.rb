
class RefreshException < StandardError
  def initialize(objeto)
    super("No es posible ejecutar refresh!(), el objeto " + objeto.to_s + " de la clase " + objeto.class.name + " no posee id")
  end
end

class ForgetException < StandardError
  def initialize(objeto)
    super("No es posible ejecutar forget!(), el objeto " + objeto.to_s + " de la clase " + objeto.class.name + " no posee id")
  end
end