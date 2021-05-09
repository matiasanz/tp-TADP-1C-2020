require 'ORM'

class Prueba
    def materia
        :tadp
    end
end

class Personaje
    has_one String, :nombre
    has_one Numeric, :velocidad

    attr_accessor :atributoNoPersistible

    def initialize(nombre=nil, velocidad=nil)
        @nombre = nombre
        @velocidad = velocidad

        @atributoNoPersistible = "Is it future or is it past"
    end
end

class Ladron < Personaje
    has_one Numeric, :sigilo

    def initialize(nombre=nil, velocidad=nil, sigilo=nil)
        super(nombre, velocidad)
        @sigilo = sigilo
    end
end