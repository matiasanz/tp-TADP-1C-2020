require_relative 'Util'
require_relative 'Atributos'

module EntidadPersistible

  include Util

  def atributos_persistibles
    @atributos_persistibles ||= []
  end

  def no_blank
    @no_blank ||= []
  end

  def from
    @from ||= {}
  end

  def to
    @to ||= {}
  end

  def validate
    @validate ||= {}
  end

  def default
    @default ||= {}
  end

  def modulos_hijos
    @modulos_hijos ||= []
  end

  def has_one(tipo_atributo, params)
    agregar_atributo(AtributoSimple.new(params[:named], tipo_atributo), params)
    self
  end

  def has_many(tipo_atributo, params)
    agregar_atributo(AtributoMultiple.new(params[:named], tipo_atributo), params)
    self
  end

  def agregar_atributo(atributo, params)
    attr_accessor params[:named]
    self.atributos_persistibles.each { |atr| atributos_persistibles.delete(atr) if atr.nombre == params[:named]}
    self.atributos_persistibles.push(atributo)
    self.no_blank.push(params[:named]) if params[:no_blank]
    self.from[params[:named]] = params[:from] if params[:from]
    self.to[params[:named]] = params[:to] if params[:to]
    self.validate[params[:named]] = params[:validate] unless params[:validate].nil?
    self.default[params[:named]] = params[:default] unless params[:default].nil?
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
    if ancestors[1].is_a?(EntidadPersistible)
      (atributos_persistibles + ancestors[1].atributos_persistibles_totales).uniq
    else
      atributos_persistibles
    end
  end

# ESTABA EN INSTANCIAPERSISTIBLE

  def tiene_valor_default(atributo, valor)
    valor.nil? && !default[atributo.nombre].nil?
  end


# VALIDACIONES  << ---------------------------------------

  def validar_todo(atributo, valor)
    validar_tipo(atributo, valor)
    validar_no_blank(atributo.nombre, valor)
    validar_from(atributo, valor)
    validar_to(atributo, valor)
    validar_block_validate(atributo.nombre, valor)
  end

  def validar_tipo(atributo, valor)
    if valor.nil?
      # no debe hacer nada
    elsif atributo.tipo == Boolean
      raise TipoDeDatoException.new(self, atributo.nombre, atributo.tipo) unless valor.is_a?(Boolean)
    elsif atributo.tipo == Numeric
      raise TipoDeDatoException.new(self, atributo.nombre, atributo.tipo) unless valor.is_a?(Numeric)
    elsif atributo.tipo == String
      raise TipoDeDatoException.new(self, atributo.nombre, atributo.tipo) unless valor.is_a?(String)
    else
      if valor.is_a?(InstanciaPersistible)
        valor.validate!
      else
        raise TipoDeDatoException.new(self, atributo.nombre, atributo.tipo)
      end
    end
  end

  def validar_no_blank(nombre_atributo, valor)
    if (valor.nil? || valor == "") && no_blank.include?(nombre_atributo)
      raise NoBlankException.new(self, nombre_atributo)
    end
  end

  def validar_from(atributo, valor)
    if atributo.tipo == Numeric && from[atributo.nombre] && from[atributo.nombre] > valor
      raise FromException.new(self, atributo.nombre, from[atributo.nombre])
    end
  end

  def validar_to(atributo, valor)
    if atributo.tipo == Numeric && to[atributo.nombre] && to[atributo.nombre] < valor
      raise ToException.new(self, atributo.nombre, to[atributo.nombre])
    end
  end

  def validar_block_validate(nombre_atributo, valor)
    if validate[nombre_atributo] && !valor.instance_eval(&validate[nombre_atributo])
      raise BlockValidateException.new(self, nombre_atributo, validate[nombre_atributo])
    end
  end

end
