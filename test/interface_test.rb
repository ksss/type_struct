require "type_struct"

module InterfaceTest
  Interface = TypeStruct::Interface
  def test_initialize(t)
    unless Interface === Interface.new
      t.error("return value was break")
    end
    unless Interface === Interface.new(:foo)
      t.error("return value was break")
    end
    unless Interface === Interface.new(:foo, :bar)
      t.error("return value was break")
    end
  end

  Reader = Interface.new(:read)
  Writer = Interface.new(:write)
  ReadWriter = Interface.new(:read, :write)

  def test_equal(t)
    r = Object.new
    def r.read
    end
    case r
    when Reader
    else
      t.error("expect Reader === r is true")
    end

    w = Object.new
    def w.write
    end
    case w
    when Writer
    else
      t.error("expect Writer === w is true")
    end

    case r
    when ReadWriter
      t.error("expect ReadWriter === r is false")
    end
  end

  def test_or(t)
    r_or_w = Reader | Writer
    r = Object.new
    def r.read
    end

    case r
    when r_or_w
    else
      t.error("expect rw === r is true")
    end
  end
end
