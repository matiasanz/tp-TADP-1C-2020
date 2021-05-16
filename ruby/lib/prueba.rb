require 'd_ORM'

class Prueba
    def materia
        :tadp
    end
end

class Personaje
    has_one String, :nombre
    has_one Numeric, :comicidad
    has_one Boolean, :enojon

    attr_accessor :atributoNoPersistible, :enojon

    def initialize(nombre, comicidad)
        @nombre = nombre
        @comicidad = comicidad
        @enojon = true

        @atributoNoPersistible = "¡No me vean!"
    end

    def ==(otro)
        @id==otro.id and @nombre==otro.instance_variable_get(:@nombre) and @comicidad==otro.instance_variable_get(:@comicidad)
    end
end

class Ladron < Personaje
    has_one Numeric, :sigilo

    attr_accessor :nombre, :comicidad, :sigilo

    def initialize(nombre, comicidad, sigilo)
        super(nombre, comicidad)
        @sigilo = sigilo
    end

    def ==(otro)
        @sigilo==otro.sigilo and super
    end

end

class LadronDeSonrisas < Ladron
    def initialize
        super('pepe argento', 370, 95)
    end
end

class Mascota
    has_one String, :nombre
    has_one Personaje, :duenio
    has_one Boolean, :hambriento

    attr_accessor :duenio, :nombre, :hambriento

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
    has_one ClaseMuyCompuesta, :atributoMuyCompuesto
    has_one Mascota, :mascota

    attr_accessor :atributoMuyCompuesto, :mascota

    def initialize(mascota, atributoMuyCompuesto)
        @mascota = mascota
        @atributoMuyCompuesto = atributoMuyCompuesto
    end

    def ==(otra)
        @mascota==otra.mascota and @atributoMuyCompuesto==otra.atributoMuyCompuesto
    end
end
