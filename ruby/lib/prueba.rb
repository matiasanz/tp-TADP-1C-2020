class Class
    def has_one(tipo, named)

        if @atributosPersistibles.nil?
            @atributosPersistibles = {}
        end

        @atributosPersistibles[named] = tipo
    end

    def atributos_persistibles()
        @atributosPersistibles
    end
end

class Object

    attr_accessor id

    def save!
        self.class.atributos_persistibles.each do |nombre,tipo|
            simboloAtributo = "@#{nombre}".to_sym
            valor = instance_variable_get(simboloAtributo)

            persistir(nombre,tipo,valor)
        end
    end

    def persistir(named, tipo, valor)
        puts "Persisti nombre: #{named}, tipo: #{tipo}, valor: #{valor.to_s.inspect}"
    end

end

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