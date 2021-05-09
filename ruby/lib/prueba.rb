require 'ORM'

class Prueba

    has_one(String, :nombreAlumno)
    has_one(Numeric, :nota)

    def initialize
        @nota = 8
        @nombreAlumno = "Pepe"
    end

    def materia
        :tadp
    end

end

class Personaje
    has_one String, :nombre
    has_one Numeric, :velocidad

    attr_accessor :atributoNoPersistible

    def initialize(nombre, velocidad)
        @nombre = nombre
        @velocidad = velocidad

        @atributoNoPersistible = "Is it future or is it past"
    end
end

class Ladron < Personaje
    has_one Numeric, :sigilo

    def initialize(nombre, velocidad, sigilo)
        super(nombre, velocidad)
        @sigilo = sigilo
    end
end