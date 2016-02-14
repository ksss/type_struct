require "type_struct/union"

class TypeStruct
  class ArrayOf
    include Unionable
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
  end
end
