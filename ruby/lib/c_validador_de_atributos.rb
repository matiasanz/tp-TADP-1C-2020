require 'b_atributos_persistibles'

module ORM

    class ValidadorDeAtributo
        def initialize(validadores)
            @validadores = validadores
        end

        def validar(atributo, objeto)
            erroresDetectados = @validadores.select{|v| not v.call(objeto)}

            unless erroresDetectados.empty?
                raise AtributoPersistibleException.new(atributo, objeto, erroresDetectados)
            end
        end
    end

    module ValidacionesFactory

        def self.from_args(tipo, args)
            raise ValidacionNoAdmitidaException.new(tipo, [:from, :to]) unless tipo<=Numeric or (args[:from].nil? and args[:to].nil?)
            validaciones = [tipo(tipo)] + args.filter_map {|nombre,arg| get_validacion(nombre, arg) if arg}
            ValidadorDeAtributo.new(validaciones)
        end

        def self.tipo(tipo)
            validador_revisado("tipo", "no es un #{tipo.to_s}", tipo, Module) {|o| o.nil? or o.is_a? tipo}
        end

        def self.to(maximo)
            validador_revisado("to", "menor o igual a #{maximo.to_s}", maximo, Numeric) {|o| o.nil? or o <= maximo}
        end

        def self.from(minimo)
            raise CampoIncorrectoException.new(minimo, Numeric, "from") unless minimo.is_a?Numeric
            validador("from", "mayor o igual a #{minimo.to_s}") {|o| o.nil? or o >= minimo}
        end

        def self.validate(accion)
            validador_revisado("validate", "No cumple condicion establecida", accion, Proc) {|o| o.instance_eval(&accion)}
        end

        def self.no_blank(arg = true)
            validador_revisado("no_blank", "Se obtuvo blank", arg, Boolean) {|o| not (o.nil?) } unless not arg
        end

        private
        def self.get_validacion(nombre, arg)
            raise ValidacionInexistenteException.new(nombre) unless self.respond_to?(nombre, false)
            self.send(nombre, arg)
        end

        def self.validador_revisado(nombre, mensaje, arg, tipo, &accion)
            raise CampoIncorrectoException.new(arg, tipo, nombre) unless arg.is_a? tipo
            validador(nombre, mensaje, &accion)
        end

        def self.validador(nombre, mensaje, &accion)
            val = proc &accion
            val.define_singleton_method(:nombre) {nombre}
            val.define_singleton_method(:mensaje) {mensaje}
            val
        end
    end
end