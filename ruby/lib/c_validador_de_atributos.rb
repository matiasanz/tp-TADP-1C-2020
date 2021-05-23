require 'b_atributos_persistibles'

class ValidadorDeAtributo
    attr_accessor :no_blank, :from, :to, :validate

    def initialize(clase, no_blank: false, from: nil, to: nil, validate: lambda{|_| true})
        raise CampoIncorrectoException.new(no_blank, Boolean, "no_blank") unless no_blank.is_a? Boolean
        raise CampoIncorrectoException.new(from, Numeric, "from") unless from.is_a?Numeric or from.nil?
        raise CampoIncorrectoException.new(to, Numeric, "to") unless to.is_a?Numeric or to.nil?
        raise CampoIncorrectoException.new(validate, [Proc, Lambda], "validate") unless validate.is_a?Proc or validate.lambda?

        unless clase <= Numeric
            raise ValidacionNoAdmitidaException.new(clase, "from") unless from.nil?
            raise ValidacionNoAdmitidaException.new(clase, "to") unless to.nil?
        end

        @no_blank=no_blank
        @from=from
        @to=to
        @validate=validate
    end

    def validar(dato)
        raise BlankException.new(dato) unless cumple_no_blank?(dato)
        raise ValidateException.new(dato) unless cumple_validate?(dato)
        raise RangoExcedidoException.new(dato, @from, @to) unless cumple_rango?(dato)
    end

    def validar_tipo(objeto)
        raise TipoErroneoException.new(objeto, @clase) unless objeto.is_a? @clase or objeto.nil?
    end

    def cumple_no_blank?(dato) #TODO mejorar la excepcion
        not (@no_blank and dato.nil?)
    end

    def cumple_validate?(dato)
        dato.instance_eval(&@validate)
    end

    def cumple_rango?(dato)
        (@from.nil? or @from<=dato) and (@to.nil? or dato<=@to)
    end
end
