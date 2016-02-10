require "type_struct/array_of"

module ArrayOfTest
  def test_initialize(t)
    unless ArrayOf === ArrayOf.new(Integer)
      t.error("failed when array of integer")
    end
  end

  def test_equal(t)
    int = ArrayOf.new(Integer)
    str = ArrayOf.new(String)

    unless int === []
      t.error("empty array check was failed")
    end

    unless int === [1, 2, 3]
      t.error("array of integer check was failed")
    end

    unless str === %w(foo bar baz)
      t.error("array of string check was failed")
    end

    if str === [1, 2, 3]
      t.error("array of integer is not string")
    end
  end
end
