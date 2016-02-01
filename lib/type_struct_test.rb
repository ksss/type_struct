require 'type_struct'

module TypeStructTest
  class Dummy < TypeStruct.new(
    str: String,
    num: Integer,
    reg: /abc/,
    ary: { type: [Integer, Float], nilable: true },
    any: Object,
  ); end

  class Bar < TypeStruct.new(
    baz: [Integer, NilClass],
    qux: Hash,
  ); end

  class Foo < TypeStruct.new(
    nil: { type: NilClass, nilable: true },
    bar: Bar,
  ); end

  def test_s_from_hash(t)
    begin
      Foo.from_hash(bar: { baz: [1, 2, 3] })
    rescue TypeError
    else
      t.error("Bar.qux is not able to nil but accepted")
    end

    begin
      Foo.from_hash(bar: { baz: [1, 2, 3] , qux: { str: "str" } }, nil: 1)
    rescue TypeError
    else
      t.error("Bar.qux is not able to nil but accepted")
    end

    foo = Foo.from_hash(bar: { baz: [1, 2, 3], qux: { str: "str" } }, nil: nil)
    unless TypeStruct === foo
      t.error("return value type was break")
    end
    unless Foo === foo
      t.error("return value type was break")
    end

    begin
      Foo.from_hash(bar: { baz: [1, nil, 3], qux: { str: "str" } })
    rescue => e
      t.error("Bar.baz is able to nil but raise error #{e.class}: #{e.message}")
    end

    begin
      Foo.from_hash(bar: { baz: nil, qux: { str: "str" } })
    rescue TypeError
    else
      t.error('Bar.baz is not able to nil')
    end

    expect = Foo.new(bar: Bar.new(baz: [1, 2, 3], qux: { str: "str" }))
    actual = Foo.from_hash(bar: { baz: [1, 2, 3], qux: { str: "str" } })
    if expect != actual
      t.error("expect #{expect} got #{actual}")
    end

    noteq = Foo.from_hash(bar: { baz: [1, 2, 4], qux: { str: "str" } })
    if expect == noteq
      t.error("expect #{expect} not equal #{noteq}")
    end

    noteq = Foo.from_hash(bar: { baz: [1, 2, nil], qux: { str: "str" } })
    if expect == noteq
      t.error("expect #{expect} not equal #{noteq}")
    end
  end

  def test_s_members(t)
    m = Dummy.members
    expect = { str: String, num: Integer, reg: /abc/, ary: { type: [Integer, Float], nilable: true }, any: Object }
    unless m == expect
      t.error("expect #{expect} got #{m}")
    end
  end

  def test_s_type(t)
    m = Dummy.members
    m.each do |k, v|
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

  def test_initialize(t)
    expects = { str: 'aaa', num: 123, reg: 'abc', ary: [1.1, 1], any: [1, 'bbb'] }
    dummy = Dummy.new(str: 'aaa', num: 123, reg: 'abc', ary: [1.1, 1], any: [1, 'bbb'])
    expects.each do |k, v|
      unless dummy[k] == v
        t.error("expect #{dummy[k]} got #{v}")
      end
    end
  end

  def test_eq(t)
    dummy1 = Dummy.new(str: 'aaa', num: 123, reg: 'abc', ary: [1.1, 1], any: [1, 'bbb'])
    dummy2 = Dummy.new(str: 'aaa', num: 123, reg: 'abc', ary: [1.1, 1], any: [1, 'bbb'])
    dummy3 = Dummy.new(str: 'bbb', num: 123, reg: 'abc', ary: [1.1, 1], any: [1, 'bbb'])
    unless dummy1 == dummy2
      t.error('members not equal')
    end
    unless dummy1 != dummy3
      t.error('members equal')
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
    expects = {str: "aaa", num: 123, reg: "abcde", any: [1, "bbb"]}
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
    %i(str num reg).each do |k, v|
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
    any: Object
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
