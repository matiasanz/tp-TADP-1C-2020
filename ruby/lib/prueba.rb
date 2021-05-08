require 'ORM'

class Prueba

    has_one(:number, :unNumero)
    has_one(:string, :nombre)

    def initialize
        @unNumero = 4
        @nombre = "Pepe"
    end

    def materia
        :tadp
    end

end