require 'ORM'

class Prueba

    has_one(:string, :nombreAlumno)
    has_one(:number, :nota)

    def initialize
        @nota = 8
        @nombreAlumno = "Pepe"
    end

    def materia
        :tadp
    end

end

class Parcialito < Prueba
    has_one(:string, :nombreAyudante)

    def initialize
        super
        @nombreAyudante = "Diego"
    end
end