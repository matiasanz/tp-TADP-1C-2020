#************ Utilidades ***********************

class Symbol
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
