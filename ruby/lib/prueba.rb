require 'd_ORM'

class Prueba
    def materia
        :tadp
    end
end

class Personaje
    extend ClasePersistible

    has_one String, named: :nombre
    has_one Numeric, named: :comicidad
    has_one Boolean, named: :enojon

    attr_accessor :atributoNoPersistible

    def initialize(nombre, comicidad)
        @nombre = nombre
        @comicidad = comicidad
        @enojon = true

        @atributoNoPersistible = "¡No se rian! podrian tener un hijo igual"
    end

    def ==(otro)
        @id==otro.id and @nombre==otro.nombre and @comicidad==otro.comicidad
    end
end

class Ladron < Personaje
    has_one Numeric, named: :sigilo

    def initialize(nombre, comicidad, sigilo)
        super(nombre, comicidad)
        @sigilo = sigilo
    end

    def ==(otro)
        super and @sigilo==otro.sigilo
    end

end

class LadronDeSonrisas < Ladron
    def initialize
        super('pepe argento', 370, 95)
    end
end

class Mascota
    has_one String, named: :nombre
    has_one Personaje, named: :duenio
    has_one Boolean, named: :hambriento

    def initialize(nombre, duenio, hambriento)
        @nombre=nombre
        @duenio=duenio
        @hambriento=hambriento
    end

    def ==(otra)
        @nombre == otra.nombre and @duenio==otra.duenio and @hambriento==otra.hambriento
    end
end

class ClaseMuyCompuesta
    has_one ClaseMuyCompuesta, named: :atributoMuyCompuesto
    has_one Mascota, named: :mascota

    def initialize(mascota, atributoMuyCompuesto)
        @mascota = mascota
        @atributoMuyCompuesto = atributoMuyCompuesto
    end

    def ==(otra)
        @mascota==otra.mascota and @atributoMuyCompuesto==otra.atributoMuyCompuesto
    end
end
