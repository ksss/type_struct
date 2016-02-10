require "type_struct/union"
require "type_struct/array_of"
require "type_struct/hash_of"
require "type_struct/interface"

class TypeStruct
  module UnionExt
    refine Class do
      include Unionable
    end
  end
end

ArrayOf = TypeStruct::ArrayOf
HashOf = TypeStruct::HashOf
Union = TypeStruct::Union
UnionExt = TypeStruct::UnionExt
Interface = TypeStruct::Interface
