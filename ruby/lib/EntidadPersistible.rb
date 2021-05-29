require_relative 'Util'
require_relative 'Atributos'

module EntidadPersistible

  include Util

  def atributos_persistibles
    @atributos_persistibles ||= []
  end

  def modulos_hijos
    @modulos_hijos ||= []
  end

  def has_one(tipo_atributo, params)
    agregar_atributo(AtributoSimple.new(tipo_atributo, params))
    self
  end

  def has_many(tipo_atributo, params)
    agregar_atributo(AtributoMultiple.new(tipo_atributo, params))
    self
  end

  def agregar_atributo(atributo)
    attr_accessor atributo.nombre
    self.atributos_persistibles.each { |atr| atributos_persistibles.delete(atr) if atr.nombre == atributo.nombre }
    self.atributos_persistibles.push(atributo)
    self
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

  #naturalmente falla si el metodo tiene aridad != 0, porque asi esta definido en "respond_to_missing?"
  def method_missing(mensaje, *args, &bloque)
    if respond_to?(mensaje, false)
      all_instances.select { |instancia| instancia.send(sin_find_by_(mensaje)) == args[0] }
    else
      super
    end
  end

  def atributos_persistibles_totales
    ancestros = ancestors
    ancestros.delete_at(0)
    padre = nil
    padre = ancestros.find { |a| a.is_a?(EntidadPersistible) } unless ancestros.nil?
    if padre.nil?
      atributos_persistibles
    else
      totales = atributos_persistibles + padre.atributos_persistibles_totales
      totales.uniq {|atr| atr.nombre}
    end
  end

end
