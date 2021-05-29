require 'b_atributos_persistibles'

class ValidadorDeAtributo
    attr_accessor :no_blank, :from, :to, :validate

    def initialize(clase, validaciones)
        @no_blank= validaciones[:no_blank] || false
        @from= validaciones[:from]
        @to=validaciones[:to]
        @validate=validaciones[:validate] || lambda{|_| true}

        unless clase <= Numeric
            raise ValidacionNoAdmitidaException.new(clase, "from") unless @from.nil?
            raise ValidacionNoAdmitidaException.new(clase, "to") unless @to.nil?
        end

        raise CampoIncorrectoException.new(@no_blank, Boolean, "no_blank") unless @no_blank.is_a? Boolean
        raise CampoIncorrectoException.new(@from, Numeric, "from") unless @from.is_a?Numeric or @from.nil?
        raise CampoIncorrectoException.new(@to, Numeric, "to") unless @to.is_a?Numeric or @to.nil?
        raise CampoIncorrectoException.new(@validate, [Proc, Lambda], "validate") unless @validate.is_a?Proc or @validate.lambda?
    end

    def validar(atributo, dato)
        validar_tipo(atributo, dato)
        raise RangoExcedidoException.new(atributo, dato, @from, @to) unless cumple_rango?(dato)
        raise BlankException.new(atributo, dato) unless cumple_no_blank?(dato)
        raise ValidateException.new(atributo, dato) unless cumple_validate?(dato)
    end

    def validar_tipo(atributo, dato)
        clase = atributo.clase
        raise TipoErroneoException.new(dato, clase) unless dato.is_a? clase or dato.nil?
    end

    def cumple_no_blank?(dato)
        not (@no_blank and dato.nil?)
    end

    def cumple_validate?(dato)
        dato.instance_eval(&@validate)
    end

    def cumple_rango?(dato)
        (@from.nil? or @from<=dato) and (@to.nil? or dato<=@to)
    end
end
