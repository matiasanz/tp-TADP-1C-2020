
module EntidadPersistible

  def modulos_hijos
    @modulos_hijos ||= []
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

end