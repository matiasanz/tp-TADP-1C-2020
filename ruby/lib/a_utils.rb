#************ Utilidades ***********************

class Symbol
    # TODO está bien que tengan estos métodos para ayudarse
    # pero creo que les va a ser más facil si la diferencia entre
    # el "nombre" de un atributo y la forma de utilizarlo para leerlo
    # en una instancia lo encapsulan adentro del strategy de atributos persistibles
    def to_param
        "@#{self.to_s}".to_sym
    end

    def param?
        self.to_s.start_with? '@'
    end
end

class String
    def to_class
        Object.const_get(self)
    end
end

# **************** Booleanos *****************

module Boolean
end

class TrueClass
    include Boolean
end

class FalseClass
    include Boolean
end
