class TypeStruct
  require "type_struct/version"

  class NoMemberError < StandardError
  end

  def initialize(**arg)
    self.class.members.each do |k, _|
      self[k] = arg[k]
    end
  end

  def ==(other)
    return false unless TypeStruct === other
    return false unless to_h == other.to_h
    true
  end

  def []=(k, v)
    __send__("#{k}=", v)
  end

  def [](k)
    __send__(k)
  end

  def inspect
    m = to_h.map do |k, v|
      "#{k}=#{v.inspect}"
    end
    "#<#{self.class} #{m.join(', ')}>"
  end

  def to_h
    m = {}
    self.class.members.each do |k, _|
      m[k] = self[k]
    end
    m
  end

  class << self
    def from_hash(h)
      h.map { |k, v|
        if members[k].ancestors.include?(TypeStruct)
          new(k => members[k].new(v))
        else
          new k => v
        end
      }.first
    end

    def members
      const_get(:MEMBERS)
    end

    def type(k)
      members[k]
    end

    def valid?(k, v)
      t = type(k)
      unless Hash === t
        t = { type: t, nilable: false }
      end
      if t[:nilable] == true && v.nil?
        true
      elsif Array === t[:type]
        return false if v.nil?
        v.all? { |i| t[:type].any? { |c| c === i } }
      elsif TypeStruct === v
        t[:type] == v.class
      else
        t[:type] === v
      end
    end

    alias original_new new
    def new(**args)
      Class.new(TypeStruct) do
        const_set :MEMBERS, args

        class << self
          def new(*args)
            original_new(*args)
          end
        end

        args.keys.each do |k, _|
          define_method(k) do
            instance_variable_get("@#{k}")
          end

          define_method("#{k}=") do |v|
            raise TypeStruct::NoMemberError unless respond_to?(k)
            unless self.class.valid?(k, v)
              raise TypeError, "`#{k.inspect}' expect #{self.class.type(k)} got #{v.inspect}"
            end
            instance_variable_set("@#{k}", v)
          end
        end
      end
    end
  end
end
