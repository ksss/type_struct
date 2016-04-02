require "type_struct"
require "type_struct/ext"

module TypeStructTest
  using TypeStruct::Union::Ext

  class Dummy < TypeStruct.new(
    str: String,
    num: Integer,
    reg: /abc/,
    ary: ArrayOf(Integer | Float) | NilClass,
    any: Object,
  ); end

  BoolClass = TrueClass | FalseClass
  C = TypeStruct.new(
    a: ArrayOf(BoolClass),
  )
  B = TypeStruct.new(
    a: Integer,
    b: BoolClass,
    c: ArrayOf(Integer),
    d: ArrayOf(BoolClass),
    e: C,
  )
  A = TypeStruct.new(
    a: ArrayOf(Integer),
    b: ArrayOf(BoolClass),
    c: BoolClass,
    d: B,
    e: ArrayOf(B),
    f: HashOf(String, Integer),
  )

  def test_s_from_hash_a(t)
    a = A.from_hash(
      a: [1, 2, 3],
      b: [false, true, false],
      c: false,
      d: { a: 1, b: false, c: [1, 2, 3], d: [false], e: { a: [true] } },
      e: [
        { a: 1, b: false, c: [1, 2, 3], d: [false], e: { a: [true] } },
        { a: 2, b: true, c: [1, 2, 3], d: [false], e: { a: [true] } },
        { a: 3, b: true, c: [1, 2, 3], d: [false], e: { a: [true] } },
      ],
      f: {
        "a" => 1,
        "c" => 2,
      },
    )
    aa = A.new(
      a: [1, 2, 3],
      b: [false, true, false],
      c: false,
      d: B.new(a: 1, b: false, c: [1, 2, 3], d: [false], e: C.new(a: [true])),
      e: [
        B.new(a: 1, b: false, c: [1, 2, 3], d: [false], e: C.new(a: [true])),
        B.new(a: 2, b: true, c: [1, 2, 3], d: [false], e: C.new(a: [true])),
        B.new(a: 3, b: true, c: [1, 2, 3], d: [false], e: C.new(a: [true])),
      ],
      f: {
        "a" => 1,
        "c" => 2,
      },
    )
    unless A === a
      t.error("instance type miss")
    end

    unless a == aa
      t.error("not same new and from_hash")
    end
  end

  def test_hash_of(t)
    b = TypeStruct.new(b: Integer)
    hc = TypeStruct.new(
      a: HashOf(Symbol, b),
    )

    h = hc.new(
      a: { sym: b.new(b: 1) },
    )
    unless 1 === h.a[:sym].b
      t.error("assign failed")
    end

    begin
      hc.new(
        a: [],
      )
    rescue TypeStruct::MultiTypeError
    else
      t.error("TypeError was not railsed")
    end

    hh = hc.from_hash(
      a: { sym: { b: 1 } },
    )
    unless hh == h
      t.error("new and from_hash dose not make equal object")
    end

    begin
      hh = hc.from_hash(a: 1)
    rescue TypeError
    else
      t.error("TypeError dose not raise error")
    end

    hsbn = TypeStruct.new(
      a: HashOf(Symbol, b) | NilClass,
    )
    begin
      hsbn.from_hash(a: [])
    rescue TypeStruct::UnionNotFoundError
    rescue => e
      t.error("Unexpected error #{e.class}: #{e.message}")
    else
      t.error("Unexpected behavior")
    end

    begin
      hsbn.from_hash(a: {a: {b: 1.1}})
    rescue TypeStruct::UnionNotFoundError
    rescue => e
      t.error("Unexpected error #{e.class}: #{e.message}")
    else
      t.error("Unexpected behavior")
    end

    begin
      hsbn.from_hash(a: {"a" => {b: 1}})
    rescue TypeStruct::MultiTypeError
    rescue => e
      t.error("Unexpected error #{e.class}: #{e.message}")
    else
      t.error("Unexpected behavior")
    end

    begin
      hsbn.from_hash(a: {"a" => {b: 1.1}})
    rescue TypeStruct::UnionNotFoundError
    rescue => e
      t.error("Unexpected error #{e.class}: #{e.message}")
    else
      t.error("Unexpected behavior")
    end
  end

  def test_array_of(t)
    a = TypeStruct.new(a: Integer)
    b = TypeStruct.new(a: ArrayOf(a))
    bb = b.new(a: [a.new(a: 1), a.new(a: 2), a.new(a: 3)])
    unless b === bb
      t.error("type error")
    end

    unless bb == b.from_hash(a: [{ a: 1 }, { a: 2 }, { a: 3 }])
      t.error("from_hash error")
    end
  end

  def test_array_of_error(t)
    a = TypeStruct.new(a: ArrayOf(Integer))
    begin
      a.from_hash(a: [1.1])
    rescue TypeError
    rescue => e
      t.error("Unexpected error #{e.class}")
    else
      t.error("Nothing raised TypeError")
    end

    b = TypeStruct.new(a: ArrayOf(Integer) | NilClass)
    begin
      b.from_hash(a: [1.1])
    rescue TypeStruct::UnionNotFoundError
    rescue => e
      t.error("Unexpected error #{e.class}")
    else
      t.error("Nothing raised TypeStruct::UnionNotFoundError")
    end

    c = TypeStruct.new(c: Integer)
    d = TypeStruct.new(d: ArrayOf(c) | NilClass)
    begin
      d.from_hash(d: [{c: 1.1}])
    rescue TypeStruct::UnionNotFoundError
    rescue => e
      t.error("Unexpected error #{e.class}")
    else
      t.error("Nothing raised TypeStruct::UnionNotFoundError")
    end
  end

  def test_s_from_hash(t)
    bar = TypeStruct.new(
      baz: ArrayOf(Integer | NilClass),
    )
    foo = TypeStruct.new(
      nil: NilClass,
      bar: bar,
    )

    f = foo.from_hash(bar: { baz: [1, 2, 3] })
    unless foo === f
      t.error("return value was break")
    end

    begin
      foo.from_hash(bar: { baz: [1, 2, "3"] })
    rescue TypeStruct::UnionNotFoundError
    else
      t.error("'3' is not valid value for Baz.baz:#{Bar.definition.fetch(:baz)}")
    end

    f = foo.from_hash("bar" => { "baz" => [1, 2, 3] })
    unless foo === f
      t.error("return value was break")
    end

    f = foo.from_hash(bar: { baz: [1, 2, 3] }, nil: nil)
    unless TypeStruct === f
      t.error("return value type was break")
    end
    unless foo === f
      t.error("return value type was break")
    end

    begin
      foo.from_hash(bar: { baz: [1, nil, 3] })
    rescue => e
      t.error("Bar.baz is able to nil but raise error #{e.class}: #{e.message}")
    end

    begin
      foo.from_hash(bar: { baz: nil })
    rescue TypeError
    else
      t.error("Bar.baz is not able to nil")
    end
  end

  def test_s_from_hash_with_other_object(t)
    a = TypeStruct.new(a: Integer)
    o = Object.new
    begin
      a.from_hash(o)
    rescue TypeError => e
    rescue => e
      t.error("Unexpected error #{e.class}")
    else
      t.error("should raise TypeError")
    end

    def o.to_hash
      {a: 1}
    end
    unless a === a.from_hash(o)
      t.error("Unexpected behavior")
    end
  end

  def test_s_from_hash_with_array_of(t)
    a = TypeStruct.new(a: ArrayOf(Integer))
    begin
      a.from_hash(a: 1)
    rescue TypeError => e
      unless /#a expect ArrayOf\(Integer\) got 1/ =~ e.message
        t.error("message was changed: #{e.message}")
      end
    rescue => e
      t.error("Unexpected error #{e}")
    else
      t.error("Unexpected behavior")
    end
  end

  def test_s_from_hash_with_hash_of(t)
    a = TypeStruct.new(a: HashOf(String, Integer))
    begin
      a.from_hash(a: 1)
    rescue TypeError => e
      unless /#a expect HashOf\(String, Integer\) got 1/ =~ e.message
        t.error("message was changed: #{e.message}")
      end
    rescue => e
      t.error("Unexpected error #{e}")
    else
      t.error("Unexpected behavior")
    end
  end

  def test_s_from_hash_with_not_class(t)
    a = TypeStruct.new(a: "a")
    begin
      a.from_hash(a: "b")
    rescue TypeStruct::MultiTypeError
    else
      t.error("Unexpected behavior")
    end
  end

  def test_s_from_hash_union(t)
    a = TypeStruct.new(a: Integer)
    b = TypeStruct.new(b: Integer)
    c = TypeStruct.new(c: Integer)
    u = TypeStruct::Union.new(a, b, c)
    d = TypeStruct.new(d: u)

    begin
      d.from_hash(d: { b: 1 })
    rescue => e
      t.error("Unexpected error was raised #{e.class}: #{e.message}")
    end

    begin
      d.from_hash(d: [b: 1])
    rescue TypeStruct::UnionNotFoundError => err
      unless /is not found with value/ =~ err.message
        t.error("error message was changed: '#{err.message}'")
      end
    else
      t.error("error dose not raised")
    end

    begin
      d.from_hash(d: { b: "a" })
    rescue TypeStruct::UnionNotFoundError => err
      unless /is not found with value/ =~ err.message
        t.error("error message was changed")
      end
      unless /#a expect Integer got nil/ =~ err.message
        t.error("error message was changed")
      end
      unless /#b expect Integer got "a"/ =~ err.message
        t.error("error message was changed")
      end
      unless /#c expect Integer got nil/ =~ err.message
        t.error("error message was changed")
      end
    else
      t.error("error dose not raised")
    end
  end

  def test_s_from_hash_equal(t)
    bar = TypeStruct.new(
      baz: ArrayOf(Integer | NilClass),
    )
    foo = TypeStruct.new(
      nil: NilClass,
      bar: bar,
    )

    expect = foo.new(bar: bar.new(baz: [1, 2, 3]))
    actual = foo.from_hash(bar: { baz: [1, 2, 3] })
    if expect != actual
      t.error("expect #{expect} got #{actual}")
    end

    noteq = foo.from_hash(bar: { baz: [1, 2, 4] })
    if expect == noteq
      t.error("expect #{expect} not equal #{noteq}")
    end

    noteq = foo.from_hash(bar: { baz: [1, 2, nil] })
    if expect == noteq
      t.error("expect #{expect} not equal #{noteq}")
    end
  end

  def test_s_from_hash_with_struct(t)
    quux = Struct.new(:q)

    qux = TypeStruct.new(
      quux1: quux,
      quux2: quux,
    )

    q = qux.from_hash(quux1: { q: 1 }, quux2: { q: nil })
    unless qux === q
      t.error("return value was break")
    end
    unless quux === q.quux1
      t.error("struct type was not applied")
    end
    unless 1 == q.quux1.q
      t.error("mapping failed #{q.quux.q} != 1")
    end
    unless nil == q.quux2.q
      t.error("mapping failed #{q.quux.q} != nil")
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
    unless A.valid?(:a, [1, 2, 3])
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
    b = B.new(a: 1, b: false, c: [1, 2, 3], d: [false], e: C.new(a: [true]))
    unless A.valid?(:d, b)
      t.error("TypeStruct is invalid with #{b}")
    end
  end

  def test_arrayof_type_struct_s_valid?(t)
    ary_b = [
      B.new(a: 1, b: false, c: [1, 2, 3], d: [false], e: C.new(a: [true])),
      B.new(a: 2, b: true, c: [1, 2, 3], d: [false], e: C.new(a: [true])),
      B.new(a: 3, b: false, c: [1, 2, 3], d: [false], e: C.new(a: [true])),
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

    dummy2 = Dummy.new("str" => "aaa", "num" => 123, "reg" => "abc", "ary" => [1.1, 1], "any" => [1, "bbb"])
    expects.each do |k, v|
      unless dummy2[k] == v
        t.error("expect #{dummy2[k]} got #{v}")
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

  def test_multi_type_error(t)
    a = TypeStruct.new(
      a: Integer,
      b: Integer,
      c: Integer,
    )
    begin
      a.new(
        a: 'a',
        b: 1,
        c: '1',
      )
    rescue TypeStruct::MultiTypeError => err
      unless err.errors.all? { |e| TypeError === e }
        t.error("Empty errors")
      end

      [
        /a expect Integer got "a"/,
        /c expect Integer got "1"/,
      ].each do |reg|
        unless reg =~ err.message
          t.error("should match error message #{reg} got #{err.message}")
        end
      end
    rescue => err
      raise err
    else
      t.error("Nothing raised an error")
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
