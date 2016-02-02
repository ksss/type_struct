class TypeStruct
  require "type_struct/version"

  class NoMemberError < StandardError
  end

  def initialize(**arg)
    self.class.members.each do |k|
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
    self.class.members.each do |k|
      m[k] = self[k]
    end
    m
  end

  class << self
    def from_hash(h)
      args = {}
      h.each do |k, v|
        t = type(k)
        if t.respond_to?(:members) && v.keys == t.members
          a = t.ancestors
          if a.include?(TypeStruct)
            args[k] = t.new(v)
          elsif a.include?(Struct)
            tt = t.new
            v.each { |vk, vv| tt[vk] = vv }
            args[k] = tt
          else
            raise NotImplementedError, "#{t} is not supported yet"
          end
        else
          args[k] = v
        end
      end
      new(args)
    end

    def definition
      const_get(:DEFINITION)
    end

    def members
      definition.keys
    end

    def type(k)
      t = definition[k]
      if Hash === t
        t[:type]
      else
        t
      end
    end

    def valid?(k, v)
      t = definition[k]
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
        const_set :DEFINITION, args

        class << self
          alias new original_new
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
