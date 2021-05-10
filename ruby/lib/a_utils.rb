class Symbol
    def to_param
        "@#{self.to_s}".to_sym
    end
end

module Boolean
end

class TrueClass
    include Boolean
end

class FalseClass
    include Boolean
end