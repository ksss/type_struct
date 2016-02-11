require "type_struct/union"

class TypeStruct
  class HashOf
    include Unionable

    def initialize(key_type, value_type)
      @key_type = key_type
      @value_type = value_type
    end

    def ===(other)
      other.all? do |k, v|
        @key_type === k && @value_type === v
      end
    end

    def to_s
      "#{self.class}(#{@key_type}, #{@value_type})"
    end
  end
end
