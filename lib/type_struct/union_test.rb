require "type_struct/ext"

module UnionTest
  U = Union.new(TrueClass, FalseClass)
  def test_union(t)
    unless Union === U
      t.error("union error")
    end
  end

  def test_or(t)
    if U === nil
      t.error("nil")
    end

    n = U | NilClass
    if U === nil
      t.error("nil")
    end
    unless n === nil
      t.error("nil")
    end
  end

  def test_equal(t)
    unless U === true
      t.error("union error")
    end
    unless U === false
      t.error("union error")
    end
    if U === nil
      t.error("union error")
    end
  end

  def test_class_or_is_undefined(t)
    TrueClass | FalseClass
  rescue NoMethodError
  else
    t.error("refinents miss")
  end

  using TypeStruct::Union::Ext

  def test_class_or(t)
    u = TrueClass | FalseClass
    unless u === true
      t.error("error")
    end
  end
end
