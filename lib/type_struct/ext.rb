require "type_struct"

class Object
  ArrayOf = TypeStruct::ArrayOf
  HashOf = TypeStruct::HashOf
  Union = TypeStruct::Union
  Interface = TypeStruct::Interface
end

class TypeStruct
  class ArrayOf
    def to_s
      "#{self.class.name.split('::').last}(#{@type})"
    end
    alias inspect to_s
  end

  class HashOf
    def to_s
      "#{self.class.name.split('::').last}(#{@key_type}, #{@value_type})"
    end
    alias inspect to_s
  end

  class Interface
    def to_s
      "#<#{self.class.name.split('::').last}(#{@methods.map(&:inspect).join(',')})>"
    end
    alias inspect to_s
  end

  class Union
    def to_s
      "#<#{self.class.name.split('::').last} #{@classes.join('|')}>"
    end
    alias inspect to_s
  end
end

module Kernel
  def ArrayOf(klass)
    ArrayOf.new(klass)
  end

  def HashOf(key_class, value_class)
    HashOf.new(key_class, value_class)
  end
end
