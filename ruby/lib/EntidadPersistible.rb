
module EntidadPersistible

  def modulos_hijos
    @modulos_hijos ||= []
  end

  def atributos_persistibles_totales
    ancestros = ancestors
    ancestros.delete_at(0)
    padre = nil
    unless ancestros.nil?
      padre = ancestros.find { |a| a.is_a?(EntidadPersistible) }
    end
    if padre.nil?
      atributos_persistibles    # arreglar TODO
    else
      totales = atributos_persistibles + padre.atributos_persistibles_totales  # arreglar TODO
      totales.uniq {|atr| atr.nombre}   # arreglar TODO
    end
  end

  # en AdministradorDeTabla redefino este metodo
  def all_instances
    all_instances_de_hijos
  end

  def all_instances_de_hijos
    array_aux = []
    modulos_hijos.each { |modulo| array_aux = array_aux + modulo.all_instances }
    array_aux
  end

  def respond_to_missing?(mensaje, priv = false)
    instancia = self.new
    if mensaje.to_s.start_with?("find_by_") && instancia.respond_to?(sin_find_by_(mensaje), false)
      metodo = instancia.method(sin_find_by_(mensaje))
      metodo.arity == 0 || super
    else
      super
    end
  end
  
  # TODO arreglar "sin_find_by_(mensaje)"

  #naturalmente falla si el metodo tiene aridad != 0, porque asi esta definido en "respond_to_missing?"
  def method_missing(mensaje, *args, &bloque)
    if respond_to?(mensaje, false)
      all_instances.select { |instancia| instancia.send(sin_find_by_(mensaje)) == args[0] }
    else
      super
    end
  end

end