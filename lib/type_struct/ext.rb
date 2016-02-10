require "type_struct/union"
require "type_struct/array_of"
require "type_struct/interface"

class TypeStruct
  module UnionExt
    refine Class do
      def |(other)
        Union.new(self, other)
      end
    end
  end
end

ArrayOf = TypeStruct::ArrayOf
Union = TypeStruct::Union
UnionExt = TypeStruct::UnionExt
Interface = TypeStruct::Interface
