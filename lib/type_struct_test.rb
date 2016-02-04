require "type_struct"

module TypeStructTest
  class Dummy < TypeStruct.new(
    str: String,
    num: Integer,
    reg: /abc/,
    ary: { type: [Integer, Float], nilable: true },
    any: Object,
  ); end

  class Quux < Struct.new(:q)
  end

  class Qux < TypeStruct.new(
    quux1: Quux,
    quux2: Quux,
  ); end

  class Bar < TypeStruct.new(
    baz: [Integer, NilClass],
  ); end

  class Foo < TypeStruct.new(
    nil: { type: NilClass, nilable: true },
    bar: Bar,
  ); end

  BoolClass = TrueClass | FalseClass
  C = TypeStruct.new(
    a: ArrayOf.new(BoolClass)
  )
  B = TypeStruct.new(
    a: Integer,
    b: BoolClass,
    c: ArrayOf.new(Integer),
    d: ArrayOf.new(BoolClass),
    e: C,
  )
  A = TypeStruct.new(
    a: ArrayOf.new(Integer),
    b: ArrayOf.new(BoolClass),
    c: BoolClass,
    d: B,
    e: ArrayOf.new(B),
  )

  def test_s_from_hash_a(t)
    a = A.from_hash(
      a: [1,2,3],
      b: [false, true, false],
      c: false,
      d: {a: 1, b: false, c: [1,2,3], d: [false], e: {a: [true]}},
      e: [
        {a: 1, b: false, c: [1,2,3], d: [false], e: {a: [true]}},
        {a: 2, b: true, c: [1,2,3], d: [false], e: {a: [true]}},
        {a: 3, b: true, c: [1,2,3], d: [false], e: {a: [true]}}
      ],
    )
    unless A === a
      t.error("failed")
    end
  end

  def test_s_from_hash(t)
    foo = Foo.from_hash(bar: { baz: [1, 2, 3] })
    unless Foo === foo
      t.error("return value was break")
    end

    begin
      Foo.from_hash(bar: { baz: [1, 2, 3] }, nil: 1)
    rescue TypeError
    else
      t.error("Bar.qux is not able to nil but accepted")
    end

    foo = Foo.from_hash(bar: { baz: [1, 2, 3] }, nil: nil)
    unless TypeStruct === foo
      t.error("return value type was break")
    end
    unless Foo === foo
      t.error("return value type was break")
    end

    begin
      Foo.from_hash(bar: { baz: [1, nil, 3] })
    rescue => e
      t.error("Bar.baz is able to nil but raise error #{e.class}: #{e.message}")
    end

    begin
      Foo.from_hash(bar: { baz: nil })
    rescue TypeError
    else
      t.error("Bar.baz is not able to nil")
    end
  end

  def test_s_from_hash_equal(t)
    expect = Foo.new(bar: Bar.new(baz: [1, 2, 3]))
    actual = Foo.from_hash(bar: { baz: [1, 2, 3] })
    if expect != actual
      t.error("expect #{expect} got #{actual}")
    end

    noteq = Foo.from_hash(bar: { baz: [1, 2, 4] })
    if expect == noteq
      t.error("expect #{expect} not equal #{noteq}")
    end

    noteq = Foo.from_hash(bar: { baz: [1, 2, nil] })
    if expect == noteq
      t.error("expect #{expect} not equal #{noteq}")
    end
  end

  def test_s_from_hash_with_struct(t)
    qux = Qux.from_hash(quux1: { q: 1 }, quux2: { q: nil })
    unless Qux === qux
      t.error("return value was break")
    end
    unless Quux === qux.quux1
      t.error("struct type was not applied")
    end
    unless 1 == qux.quux1.q
      t.error("mapping failed #{qux.quux.q} != 1")
    end
    unless nil == qux.quux2.q
      t.error("mapping failed #{qux.quux.q} != nil")
    end
  end

  def test_s_members(t)
    m = Dummy.members
    expect = [:str, :num, :reg, :ary, :any]
    unless m == expect
      t.error("expect #{expect} got #{m}")
    end
  end

  def test_s_type(t)
    Dummy.definition.each do |k, v|
      type = Dummy.type(k)
      if v.respond_to?(:[])
        if type != v[:type]
          t.error("expect #{v[:type]} got #{type}")
        end
      elsif type != v
        t.error("expect #{v} got #{type}")
      end
    end
  end

  def test_s_valid?(t)
    unless Dummy.valid?(:str, "abc")
      t.error('expect :str valid "abc"')
    end
    if Dummy.valid?(:str, 345)
      t.error("expect :str invalid 345")
    end
    unless Dummy.valid?(:reg, "abc")
      t.error('expect :reg valid "abc"')
    end
  end

  def test_arrayof_s_valid?(t)
    unless A.valid?(:a, [1,2,3])
      t.error("ArrayOf failed with [1,2,3]")
    end
  end

  def test_arrayof_union_s_valid?(t)
    unless A.valid?(:b, [false, true, false])
      t.error("ArrayOf failed with Union")
    end
  end

  def test_union_s_valid?(t)
    unless A.valid?(:c, false)
      t.error("Union is invalid with false")
    end
  end

  def test_type_struct_s_valid?(t)
    b = B.new(a: 1, b: false, c: [1,2,3], d: [false], e: C.new(a: [true]))
    unless A.valid?(:d, b)
      t.error("TypeStruct is invalid with #{b}")
    end
  end

  def test_arrayof_type_struct_s_valid?(t)
    ary_b = [
      B.new(a: 1, b: false, c: [1,2,3], d: [false], e: C.new(a: [true])),
      B.new(a: 2, b: true, c: [1,2,3], d: [false], e: C.new(a: [true])),
      B.new(a: 3, b: false, c: [1,2,3], d: [false], e: C.new(a: [true])),
    ]
    unless A.valid?(:e, ary_b)
      t.error("ArrayOf with TypeStruct is invalid with #{ary_b}")
    end
  end

  def test_initialize(t)
    expects = { str: "aaa", num: 123, reg: "abc", ary: [1.1, 1], any: [1, "bbb"] }
    dummy = Dummy.new(str: "aaa", num: 123, reg: "abc", ary: [1.1, 1], any: [1, "bbb"])
    expects.each do |k, v|
      unless dummy[k] == v
        t.error("expect #{dummy[k]} got #{v}")
      end
    end
  end

  def test_eq(t)
    dummy1 = Dummy.new(str: "aaa", num: 123, reg: "abc", ary: [1.1, 1], any: [1, "bbb"])
    dummy2 = Dummy.new(str: "aaa", num: 123, reg: "abc", ary: [1.1, 1], any: [1, "bbb"])
    dummy3 = Dummy.new(str: "bbb", num: 123, reg: "abc", ary: [1.1, 1], any: [1, "bbb"])
    unless dummy1 == dummy2
      t.error("members not equal")
    end
    unless dummy1 != dummy3
      t.error("members equal")
    end
  end

  def test_initialize_not_enough(t)
    _, err = go { Dummy.new(str: "aaa") }
    if err == nil
      t.error("in initialize, expect raise error since not enough members but nothing raised")
    end
  end

  def test_initialize_invalid_type(t)
    value, err = go { Dummy.new(str: "aaa", num: 123, reg: "abb", any: nil) }
    if err == nil
      t.error("invalid value expect raise error")
    end
  end

  def test_to_h(t)
    expects = { str: "aaa", num: 123, reg: "abcde", any: [1, "bbb"] }
    dummy = Dummy.new(str: "aaa", num: 123, reg: "abcde", any: [1, "bbb"])
    expects.each do |k, v|
      unless dummy[k] == v
        t.error("expect #{dummy[k]} got #{v}")
      end
    end
  end

  def test_getter(t)
    dummy = Dummy.new(str: "aaa", num: 123, reg: "abc", any: [1, "bbb"])
    _, err = go { dummy[:str] }
    if err != nil
      t.error("expect not raise error when valid value get. got #{err}")
    end
    _, err = go { dummy.str }
    if err != nil
      t.error("expect not raise error when valid value get. got #{err}")
    end

    _, err = go { dummy[:nothing] }
    if err == nil
      t.error("expect not raise error when invalid value get")
    end
    _, err = go { dummy.nothing }
    if err == nil
      t.error("expect not raise error when invalid value get")
    end
  end

  def test_setter(t)
    dummy = Dummy.new(str: "aaa", num: 123, reg: "abc", any: [1, "bbb"])
    %i(str num reg).each do |k|
      _, err = go { dummy[k] = nil }
      if err == nil
        t.error("expect raise error when invalid value set")
      end
      _, err = go { dummy.__send__("#{k}=", nil) }
      if err == nil
        t.error("expect raise error when invalid value set")
      end
    end

    _, err = go { dummy[:any] = nil }
    if err != nil
      t.error("expect not raise error when valid value set got #{err}")
    end
    _, err = go { dummy.any = nil }
    if err != nil
      t.error("expect not raise error when valid value set got #{err}")
    end

    _, err = go { dummy[:nothing] = nil }
    if err == nil
      t.error("expect not raise error when valid value set got #{err}")
    end
    _, err = go { dummy.nothing = nil }
    if err == nil
      t.error("expect not raise error when valid value set got #{err}")
    end
  end

  class Sample < TypeStruct.new(
    str: String,
    reg: /exp/,
    num: Integer,
    any: Object,
  ); end

  def example_readme
    sample = Sample.new(
      str: "instance of String",
      reg: "match to regexp",
      num: 10,
      any: true,
    )
    p sample
    p sample.to_h
    # Output:
    # #<TypeStructTest::Sample str="instance of String", reg="match to regexp", num=10, any=true>
    # {:str=>"instance of String", :reg=>"match to regexp", :num=>10, :any=>true}
  end

  private

  def go
    err = nil
    begin
      ret = yield
    rescue => e
      err = e
    end
    [ret, err]
  end
end
