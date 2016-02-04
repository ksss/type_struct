require "union"

module UnionExt
  refine Class do
    def |(other)
      Union.new(self, other)
    end
  end
end
