require_relative 'Util'
require_relative 'Atributos'

module EntidadPersistible

  include Util

  def atributos_persistibles
    @atributos_persistibles ||= {}
  end

  def atributos_has_many
    @atributos_has_many ||= []
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
    agregar_atributo(tipo_atributo, params)
    self
  end

  def has_many(tipo_atributo, params)
    agregar_atributo(tipo_atributo, params)
    atributos_has_many.push(params[:named])
    self
  end

  def agregar_atributo(tipo_atributo, params)
    attr_accessor params[:named]
    self.atributos_persistibles[params[:named]] = tipo_atributo
    self.no_blank.push(params[:named]) if params[:no_blank]
    self.from[params[:named]] = params[:from] if params[:from]
    self.to[params[:named]] = params[:to] if params[:to]
    self.validate[params[:named]] = params[:validate] unless params[:validate].nil?
    self.default[params[:named]] = params[:default] unless params[:default].nil?
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
      atributos_persistibles.merge(ancestors[1].atributos_persistibles_totales)
    else
      atributos_persistibles
    end
  end

  def atributos_has_many_totales
    if ancestors[1].is_a?(EntidadPersistible)
      (atributos_has_many + ancestors[1].atributos_has_many_totales).uniq
    else
      atributos_has_many
    end
  end

# ESTABA EN INSTANCIAPERSISTIBLE

  def obtener_valor_a_insertar(simbolo, valor)
    if atributos_has_many_totales.include?(simbolo)
      obtener_valor_has_many(simbolo, valor)
    elsif es_tipo_primitivo(atributos_persistibles_totales[simbolo])
      valor
    else
      valor.save!.id
    end
  end

  def obtener_valor_has_many(simbolo, valor)
    if es_tipo_primitivo(atributos_persistibles_totales[simbolo])
      valor.join(",")
    else
      valor.map{|instancia| instancia.save!.id}.join(",")
    end
  end

  def tiene_valor_default(simbolo, valor)
    valor.nil? && !default[simbolo].nil?
  end


# VALIDACIONES  << ---------------------------------------

  def validar_todo(atributo, valor)
    validar_tipo(atributo, valor)
    validar_no_blank(atributo, valor)
    validar_from(atributo, valor)
    validar_to(atributo, valor)
    validar_block_validate(atributo, valor)
  end

  def validar_tipo(atributo, valor)
    if valor.nil?
      # no debe hacer nada
    elsif atributos_persistibles_totales[atributo] == Boolean
      raise TipoDeDatoException.new(self, atributo, atributos_persistibles_totales[atributo]) unless valor.is_a?(Boolean)
    elsif atributos_persistibles_totales[atributo] == Numeric
      raise TipoDeDatoException.new(self, atributo, atributos_persistibles_totales[atributo]) unless valor.is_a?(Numeric)
    elsif atributos_persistibles_totales[atributo] == String
      raise TipoDeDatoException.new(self, atributo, atributos_persistibles_totales[atributo]) unless valor.is_a?(String)
    else
      if valor.is_a?(InstanciaPersistible)
        valor.validate!
      else
        raise TipoDeDatoException.new(self, atributo, atributos_persistibles_totales[atributo])
      end
    end
  end

  def validar_no_blank(atributo, valor)
    if (valor.nil? || valor == "") && no_blank.include?(atributo)
      raise NoBlankException.new(self, atributo)
    end
  end

  def validar_from(atributo, valor)
    if atributos_persistibles_totales[atributo] == Numeric && from[atributo] && from[atributo] > valor
      raise FromException.new(self, atributo, from[atributo])
    end
  end

  def validar_to(atributo, valor)
    if atributos_persistibles_totales[atributo] == Numeric && to[atributo] && to[atributo] < valor
      raise ToException.new(self, atributo, to[atributo])
    end
  end

  def validar_block_validate(atributo, valor)
    if validate[atributo] && !valor.instance_eval(&validate[atributo])
      raise BlockValidateException.new(self, atributo, validate[atributo])
    end
  end

end
