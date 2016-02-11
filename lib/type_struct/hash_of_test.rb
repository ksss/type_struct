require "type_struct/hash_of"

module HashOfTest
  def test_initialize(t)
    unless HashOf === HashOf.new(String, String)
      t.error("make hash of")
    end
  end

  def test_equal(t)
    ssh = HashOf.new(String, String)
    unless ssh === { "a" => "b", "c" => "d" }
      t.error("=== equal check failed")
    end
    if ssh === { "a" => "b", "c" => :d }
      t.error("=== equal check failed")
    end
    if ssh === { "a" => "b", :c => "d" }
      t.error("=== equal check failed")
    end

    ifh = HashOf.new(Integer, Float)
    unless ifh === { 1 => 1.0, 2 => Float::NAN }
      t.error("=== equal check failed")
    end
    if ifh === { 1 => 1, 2 => Float::NAN }
      t.error("=== equal check failed")
    end
    if ifh === { 1 => 1.0, "2" => "1" }
      t.error("=== equal check failed")
    end
  end

  def test_to_s(t)
    hash_of = HashOf.new(Symbol, Integer)
    expect = "TypeStruct::HashOf(Symbol, Integer)"
    unless expect == hash_of.to_s
      t.error("to_s string was break #{expect} != #{hash_of}")
    end
  end
end
