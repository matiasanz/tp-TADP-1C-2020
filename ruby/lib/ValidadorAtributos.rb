require_relative 'Util'

# TODO ejemplo de validador cambiando la funcionalidad un poco:
# - las exceptions no las individualice, pero podrías extender un poco el diseño para soportar eso también
# - en vez de tirar exception por cada validación incorrecta, retorno un boolean en el método "validar"
# - el único parametro de "validar" es el valor
# (ya que no voy a tirar la exception custom me ahorro el nombre de la clase... si, es más pobre para
# informar el error, pero también se puede decorar eso desde el que recibe el error, por ejemplo,
# que un "validador" tenga "nombre" y que el que lo usa luego pueda decir "el $nombre no funcionó para la $clase")
# ---
# Se podría incluso simplificar un poco más el modelo si cambias el método "validar" por "call" (termina siendo polimorfico a un proc)

class CompositeValidator
  def initialize(validadores_proc)
    @validadores = validadores_proc
  end
  # retorna false si no es valido
  def call(valor)
    @validadores.all? { |v| v.call(valor) }
  end
end

class ValidatorsBuilder
  extend Util

  # TODO este builder es una forma de construir los validadores (es como un parser)
  # Pero tranquilamente podrías crear validadores sueltos (con procs) o llamando a los métodos
  # de clase
  def self.build(tipo_atributo, params)
    validators = []
    validators.push(no_blank) if params[:no_blank]
    # hay que ver si este validador debería estar con estos otros, pero podría ser
    validators.push(validar_tipo(tipo_atributo))
    validators.push(validar_from(params[:from])) if params[:from]
    validators.push(validar_to(params[:to])) if params[:to]
    validators.push(validar_block_validate(params[:validate])) if params[:validate]
    CompositeValidator.new(validators)
  end

  def self.no_blank
    proc { |v| !v.nil? && v != "" }
  end

  def self.validar_tipo(tipo_atributo)
    proc do |v|
      (v.is_a?(InstanciaPersistible) &&
          # v.validate! debería retornar boolean para que tenga sentido esta impl :P
          true
      ) || (
      es_tipo_primitivo(tipo_atributo) &&
          !(v.class <= tipo_atributo) || !es_tipo_primitivo(tipo_atributo)
      )
    end
  end

  def self.validar_from(from)
    proc { |v| from > v }
  end

  def self.validar_to(to)
    proc { |v| to < v }
  end

  def self.validar_block_validate(block)
    proc { |v| !v.instance_eval(&block) }
  end
end

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
      if @tipo_atributo <= Numeric
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
    if valor.is_a?(InstanciaPersistible)
      valor.validate!
    elsif es_tipo_primitivo(@tipo_atributo) && !(valor.class <= @tipo_atributo) || !es_tipo_primitivo(@tipo_atributo)
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
