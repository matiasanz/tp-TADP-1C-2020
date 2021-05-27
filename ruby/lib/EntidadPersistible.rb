require_relative 'Util'

module EntidadPersistible

  include Util

  attr_reader :atributos_persistibles, :atributos_has_many, :no_blank, :from, :to, :validate, :default

  def has_one(tipo_atributo, named:, no_blank: false, from: nil, to: nil, validate: nil, default: nil)
    agregar_atributo(tipo_atributo, named, no_blank, from, to, validate, default)
    self
  end

  def has_many(tipo_atributo, named:, no_blank: false, from: nil, to: nil, validate: nil, default: nil)
    agregar_atributo(tipo_atributo, named, no_blank, from, to, validate, default)
    @atributos_has_many ||= []
    @atributos_has_many.push(named)
    self
  end

  def agregar_atributo(tipo_atributo, named, no_blank, from, to, validate, default)
    attr_accessor named
    @atributos_persistibles ||= {}
    @no_blank ||= []
    @from ||= {}
    @to ||= {}
    @validate ||= {}
    @default ||= {}
    @atributos_persistibles[named] = tipo_atributo
    @no_blank.push(named) if no_blank
    @from[named] = from if from
    @to[named] = to if to
    @validate[named] = validate if validate
    @default[named] = default if default
    self
  end

  def all_instances
    all_instances_de_hijos
  end

  def all_instances_de_hijos
    array_aux = []
    modulos_hijos.each { |modulo| array_aux = array_aux + modulo.all_instances }
    array_aux
  end

  #naturalmente falla si el metodo tiene aridad != 0, porque asi esta definido en "respond_to_missing?"
  def method_missing(mensaje, *args, &bloque)
    if respond_to?(mensaje, false) && mensaje.to_s.start_with?("find_by_")
      all_instances.select { |instancia| instancia.send(sin_find_by_(mensaje)) == args[0] }
    else
      super
    end
  end

  def respond_to_missing?(mensaje, priv = false)
    instancia = self.new
    if instancia.respond_to?(sin_find_by_(mensaje), false)
      metodo = instancia.method(sin_find_by_(mensaje))
      metodo.arity == 0 || super
    else
      super
    end
  end

end
