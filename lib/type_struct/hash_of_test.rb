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
end
