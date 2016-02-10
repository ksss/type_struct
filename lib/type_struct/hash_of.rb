require "type_struct/union"

class TypeStruct
  class HashOf
    def initialize(key_type, value_type)
      @key_type = key_type
      @value_type = value_type
    end

    def |(other)
      Union.new(self, other)
    end

    def ===(other)
      other.all? do |k, v|
        @key_type === k && @value_type === v
      end
    end
  end
end
