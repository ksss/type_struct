require "type_struct/union"

class TypeStruct
  class HashOf < TypeOf
    attr_reader :key_type, :value_type
    def initialize(key_type, value_type)
      @key_type = key_type
      @value_type = value_type
    end

    def ===(other)
      return false unless Hash === other
      other.all? do |k, v|
        @key_type === k && @value_type === v
      end
    end

    def to_s
      "#{self.class}(#{@key_type}, #{@value_type})"
    end
    alias inspect to_s

    def try_convert(key, value, errors)
      unless Hash === value
        begin
          raise TypeError, "#{self}##{key} expect #{inspect} got #{value.inspect}"
        rescue TypeError => e
          raise unless errors
          errors << e
        end
        return value
      end
      new_hash = {}
      value.each do |hk, hv|
        new_hash[hk] = TypeStruct.try_convert(@value_type, key, hv, errors)
      end
      new_hash
    end
  end
end
