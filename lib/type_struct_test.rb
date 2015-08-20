require 'type_struct'

module TypeStructTest
  class Dummy < TypeStruct.new(
    str: String,
    num: Integer,
    reg: /abc/,
    any: Object,
  ); end

  def test_s_members(t)
    m = Dummy.members
    expect = {str: String, num: Integer, reg: /abc/, any: Object}
    unless m == expect
      t.error("expect #{expect} got #{m}")
    end
  end

  def test_s_type(t)
    m = Dummy.members
    m.each do |k, v|
      unless Dummy.type(k) == v
        t.error("expect #{v} got #{Dummy.type(k)}")
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
    expects = {str: "aaa", num: 123, reg: "abc", any: [1, "bbb"]}
    dummy = Dummy.new(str: "aaa", num: 123, reg: "abc", any: [1, "bbb"])
    expects.each do |k, v|
      unless dummy[k] == v
        t.error("expect #{dummy[k]} got #{v}")
      end
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
    _, err = go { dummy[:nothing] }
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
    end

    _, err = go { dummy[:any] = nil }
    if err != nil
      t.error("expect not raise error when valid value set got #{err}")
    end

    _, err = go { dummy[:nothing] = nil }
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
      reg: "not match to regexp",
      num: 10,
      any: true,
    )
    p sample
    p sample.to_h
    # Output:
    # #<TypeStructTest::Sample str="instance of String", reg="not match to regexp", num=10, any=true>
    # {:str=>"instance of String", :reg=>"not match to regexp", :num=>10, :any=>true}
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
