class Symbol
    def to_param
        "@#{self.to_s}".to_sym
    end
end
