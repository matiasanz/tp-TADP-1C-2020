require 'e_ORM'

class Prueba
    def materia
        :tadp
    end
end

class ClaseSimple
    include ORM::ObjetoPersistible

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
        @nombre==otro.nombre and @comicidad==otro.comicidad
    end
end

class SubclaseSimple < ClaseSimple
    include ORM::ObjetoPersistible

    has_one Numeric, named: :sigilo

    def initialize(nombre, comicidad, sigilo)
        super(nombre, comicidad)
        @sigilo = sigilo
    end

    def ==(otro)
        super and @sigilo==otro.sigilo
    end

end

class SubSubclaseVacia < SubclaseSimple

    def initialize
        super('pepe argento', 370, 95)
    end
end

class ClaseCompuesta
    include ORM::ObjetoPersistible

    has_one String, named: :nombre
    has_one ClaseSimple, named: :duenio
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
    include ORM::ObjetoPersistible

    has_one ClaseMuyCompuesta, named: :atributoMuyCompuesto
    has_one ClaseCompuesta, named: :mascota

    def initialize(mascota, atributoMuyCompuesto)
        @mascota = mascota
        @atributoMuyCompuesto = atributoMuyCompuesto
    end

    def ==(otra)
        @mascota==otra.mascota and @atributoMuyCompuesto==otra.atributoMuyCompuesto
    end
end

class ClaseCompuestaDeMultiplesCompuestas
    include ORM::ObjetoPersistible

    has_many ClaseSimple, named: :personajes

    def initialize
        @personajes=[]
        @criticas=[]
    end

    def agregarPersonaje(personaje)
        @personajes << personaje
    end

    def agregarCritica(critica)
        @criticas << critica
    end
end

class ClaseCompuestaDeMultiplesSimples
    include ORM::ObjetoPersistible

    has_many Numeric, named: :resultados

    def initialize
        @resultados = []
    end

    def conResultado(rdo)
        @resultados << rdo
        self
    end
end

class ClaseDefault
    include ORM::ObjetoPersistible

    has_one String, named: :nombre, default: "Anonimo"
    has_one ClaseSimple, named: :personaje, default: ClaseSimple.new("Arbol", 0)
    def initialize(nombre, personaje)
        @nombre = nombre
        @personaje=personaje
    end
end

module MixinPersistible
    extend ORM::ModuloPersistible

    has_one Numeric, named: :danio

    def atacar(alguien)
        alguien.recibir_danio(@danio)
    end
end

class Misil
    include MixinPersistible

    def initialize(danio)
        @danio=danio
    end
end

class SubClaseConMixin < ClaseSimple
    include MixinPersistible

    attr_accessor :vida

    def initialize(nombre, comicidad, danio)
        super(nombre, comicidad)
        @vida = 100
        @danio = danio
    end

    def recibir_danio(danio)
        @vida -=danio
    end
end