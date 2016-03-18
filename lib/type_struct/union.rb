class TypeStruct
  module Unionable
    def |(other)
      Union.new(self, other)
    end
  end

  class Union
    include Enumerable

    def initialize(*classes)
      @classes = classes
    end

    def each(*args, &block)
      @classes.each(*args, &block)
    end

    def |(other)
      Union.new(*@classes, other)
    end

    def ===(other)
      @classes.any? { |c| c === other }
    end

    def to_s
      "#<#{self.class} #{@classes.join('|')}>"
    end
    alias inspect to_s

    module Ext
      refine Class do
        include Unionable
      end
    end
  end
end
