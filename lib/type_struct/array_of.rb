require "type_struct/union"

class TypeStruct
  class ArrayOf < TypeOf
    attr_reader :type
    def initialize(type)
      @type = type
    end

    def to_s
      "#{self.class}(#{@type})"
    end
    alias inspect to_s

    def ===(other)
      return false unless Array === other
      other.all? { |o| @type === o }
    end

    def try_convert(key, value, errors)
      unless Array === value
        begin
          raise TypeError, "#{self}##{key} expect #{inspect} got #{value.inspect}"
        rescue TypeError => e
          raise unless errors
          errors << e
        end
        return value
      end
      value.map { |v| TypeStruct.try_convert(@type, key, v, errors) }
    end
  end
end
