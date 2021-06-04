require 'b_atributos_persistibles'

module ORM

    class Validador
        def initialize(validadores)
            @validadores = validadores
        end

        def validar(atributo, objeto)
            erroresDetectados = @validadores.select{|v| not v.call(objeto)}

            if not erroresDetectados.empty?
                raise AtributoPersistibleException.new(atributo, objeto, erroresDetectados)
            end
        end
    end

    module ValidacionesFactory

        def self.from_args(tipo, args)
            args.filter_map {|k,v| self.send(k, v) if v and k!=:named and k!=:default}
            validaciones = [tipo(tipo)]
            validaciones << no_blank if args[:no_blank]
            validaciones << to(args[:to]) if args[:to]
            validaciones << from(args[:from]) if args[:from]
            validaciones << validate(args[:validate]) if args[:validate]
            Validador.new(validaciones)
        end

        def self.tipo(tipo)
            validador("tipo", "no es un #{tipo.to_s}") {|o| o.nil? or o.is_a? tipo}
        end

        def self.to(maximo)
            raise CampoIncorrectoException.new(maximo, Numeric, "to") unless maximo.is_a?Numeric
            validador("to", "menor o igual a #{maximo.to_s}") {|o| o.nil? or o <= maximo}
        end

        def self.from(minimo)
            raise CampoIncorrectoException.new(minimo, Numeric, "from") unless minimo.is_a?Numeric
            validador("from", "mayor o igual a #{minimo.to_s}") {|o| o.nil? or o >= minimo}
        end

        def self.validate(accion)
            raise CampoIncorrectoException.new(accion, [Proc, Lambda], simbolo) unless accion.is_a?Proc or accion.lambda?
            validador("validate", "") {|o| o.instance_eval(&accion)}
        end

        def self.no_blank(arg = true)
            raise CampoIncorrectoException.new(arg, Boolean, "no_blank") unless arg.is_a? Boolean
            validador("no_blank", "") {|o| not (o.nil?) } unless not arg
        end

        def self.validador(nombre, mensaje, &accion)
            val = proc &accion
            val.define_singleton_method(:nombre) {nombre}
            val.define_singleton_method(:mensaje) {mensaje}
            val
        end
    end
end