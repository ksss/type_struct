require "type_struct/union"

class TypeStruct
  class ArrayOf
    attr_reader :type
    def initialize(type)
      @type = type
    end

    def |(other)
      Union.new(self, other)
    end

    def to_s
      "#<#{self.class} #{@type}>"
    end
    alias inspect to_s

    def ===(other)
      return true if other.respond_to?(:empty?) && other.empty?
      return false unless other.respond_to?(:any?)
      other.any? { |o| @type === o }
    end
  end
end
