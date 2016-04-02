require "type_struct"
require "type_struct/ext"

module TypeStructBenchmarkTest
  using TypeStruct::Union::Ext

  def benchmark_new(b)
    i = 0
    while i < b.n
      TypeStruct.new(
        a: String,
        b: Integer,
        c: Regexp,
      )
      i += 1
    end
  end

  def benchmark_new_instance(b)
    t = TypeStruct.new(
      a: String,
      b: Integer,
      c: Regexp,
    )
    hash = { a: "aaa".freeze, b: 1, c: /abc/ }
    i = 0
    while i < b.n
      t.new(hash)
      i += 1
    end
  end

  A = TypeStruct.new(
    a: Integer,
  )
  B = TypeStruct.new(
    b: A,
  )
  C = TypeStruct.new(
    c: B,
  )
  D = TypeStruct.new(
    d: C,
  )
  E = TypeStruct.new(
    e: D,
  )

  def benchmark_from_hash(b)
    i = 0
    hash = { e: { d: { c: { b: { a: 1 } } } } }
    while i < b.n
      E.from_hash(hash)
      i += 1
    end
  end
end
