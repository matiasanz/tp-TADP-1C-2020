
class ValidadorAtributos

  def initialize(params, tipo)
    @params = params
    @tipo = tipo
  end

  def validar(valor, nombre_clase_error)
    validar_no_blank(valor, nombre_clase_error)
    unless valor.nil?
      validar_tipo(valor, nombre_clase_error)
      validar_block_validate(valor, nombre_clase_error)
      if @tipo == Numeric
        validar_from(valor, nombre_clase_error)
        validar_to(valor, nombre_clase_error)
      end
    end
  end

  def validar_no_blank(valor, nombre_clase_error)
    if (valor.nil? || valor == "") && @params[:no_blank]
      raise NoBlankException.new(nombre_clase_error, @params[:named])
    end
  end

  def validar_tipo(valor, nombre_clase_error)
    if @tipo == Boolean
      raise TipoDeDatoException.new(nombre_clase_error, @params[:named], @tipo) unless valor.is_a?(Boolean)
    elsif @tipo == Numeric
      raise TipoDeDatoException.new(nombre_clase_error, @params[:named], @tipo) unless valor.is_a?(Numeric)
    elsif @tipo == String
      raise TipoDeDatoException.new(nombre_clase_error, @params[:named], @tipo) unless valor.is_a?(String)
    else
      if valor.is_a?(InstanciaPersistible)
        valor.validate!
      else
        raise TipoDeDatoException.new(nombre_clase_error, @params[:named], @tipo)
      end
    end
  end

  def validar_from(valor, nombre_clase_error)
    if @params[:from] && @params[:from] > valor
      raise FromException.new(nombre_clase_error, @params[:named], @params[:from])
    end
  end

  def validar_to(valor, nombre_clase_error)
    if @params[:to] && @params[:to] < valor
      raise ToException.new(nombre_clase_error, @params[:named], @params[:to])
    end
  end

  def validar_block_validate(valor, nombre_clase_error)
    if @params[:validate] && !valor.instance_eval(&@params[:validate])
      raise BlockValidateException.new(nombre_clase_error, @params[:named], @params[:validate])
    end
  end

end
