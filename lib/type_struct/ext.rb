require "type_struct"

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
