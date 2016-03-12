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
  end

  class HashOf
    def to_s
      "#{self.class.name.split('::').last}(#{@key_type}, #{@value_type})"
    end
  end

  class Interface
    def to_s
      "#<#{self.class.name.split('::').last}(#{@methods.map(&:inspect).join(',')})>"
    end
  end

  class Union
    def to_s
      "#<#{self.class.name.split('::').last} #{@classes.join('|')}>"
    end
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
