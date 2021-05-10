require 'c_ORM'

class Prueba
    def materia
        :tadp
    end
end

class Personaje
    has_one String, :nombre
    has_one Numeric, :velocidad
    has_one Boolean, :enojon

    attr_accessor :atributoNoPersistible

    def initialize(nombre, velocidad)
        @nombre = nombre
        @velocidad = velocidad
        @enojon = true

        @atributoNoPersistible = "Is it future or is it past"
    end
end

class Ladron < Personaje
    has_one Numeric, :sigilo

    attr_accessor :nombre, :velocidad, :sigilo, :enojon

    def initialize(nombre, velocidad, sigilo)
        super(nombre, velocidad)
        @sigilo = sigilo
    end

    def equal?(otroLadron)
        @nombre==otroLadron.nombre and @sigilo==otroLadron.sigilo and @velocidad==otroLadron.velocidad
    end
end

class LadronDeSonrisas < Ladron
    def initialize
        super('anonimo', 370, 95)
    end
end