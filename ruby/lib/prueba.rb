require 'ORM'

class Prueba

    has_one("Int", :unNumero)
    has_one("String", :nombre)

    def initialize()
        @unNumero = 4
        @nombre = "Pepe"
    end

    def materia
        :tadp
    end

end