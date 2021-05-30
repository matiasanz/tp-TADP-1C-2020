require_relative 'Util'

class ValidadorAtributos

  include Util

  def initialize(params, tipo)
    @params = params
    @tipo_atributo = tipo
  end

  def validar(valor, nombre_clase_error)
    validar_no_blank(valor, nombre_clase_error)
    unless valor.nil?
      validar_tipo(valor, nombre_clase_error).validar_block_validate(valor, nombre_clase_error)
      if @tipo_atributo == Numeric
        validar_from(valor, nombre_clase_error).validar_to(valor, nombre_clase_error)
      end
    end
    self
  end

  def validar_no_blank(valor, nombre_clase_error)
    if (valor.nil? || valor == "") && @params[:no_blank]
      raise NoBlankException.new(nombre_clase_error, @params[:named])
    end
    self
  end

  def validar_tipo(valor, nombre_clase_error)
    # TODO uso <= para que valide misma clase o subtipos
    if @tipo_atributo <= Boolean
      raise TipoDeDatoException.new(nombre_clase_error, @params[:named], @tipo_atributo) unless valor.is_a?(Boolean)
    elsif @tipo_atributo <= Numeric
      raise TipoDeDatoException.new(nombre_clase_error, @params[:named], @tipo_atributo) unless valor.is_a?(Numeric)
    elsif @tipo_atributo <= String
      raise TipoDeDatoException.new(nombre_clase_error, @params[:named], @tipo_atributo) unless valor.is_a?(String)
    elsif valor.is_a?(InstanciaPersistible)
      valor.validate!
    else
      raise TipoDeDatoException.new(nombre_clase_error, @params[:named], @tipo_atributo)
    end
    self
  end

  def validar_from(valor, nombre_clase_error)
    if @params[:from] && @params[:from] > valor
      raise FromException.new(nombre_clase_error, @params[:named], @params[:from])
    end
    self
  end

  def validar_to(valor, nombre_clase_error)
    if @params[:to] && @params[:to] < valor
      raise ToException.new(nombre_clase_error, @params[:named], @params[:to])
    end
    self
  end

  def validar_block_validate(valor, nombre_clase_error)
    if @params[:validate] && !valor.instance_eval(&@params[:validate])
      raise BlockValidateException.new(nombre_clase_error, @params[:named], @params[:validate])
    end
    self
  end

end
