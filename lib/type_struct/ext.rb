require "type_struct"

class Object
  ArrayOf = TypeStruct::ArrayOf
  HashOf = TypeStruct::HashOf
  Union = TypeStruct::Union
  Interface = TypeStruct::Interface
end

module Kernel
  def ArrayOf(klass)
    ArrayOf.new(klass)
  end

  def HashOf(key_class, value_class)
    HashOf.new(key_class, value_class)
  end
end
