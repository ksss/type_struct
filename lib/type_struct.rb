require "union_ext"
require "arrayof"

using UnionExt

class TypeStruct
  require "type_struct/version"

  class NoMemberError < StandardError
  end

  def initialize(arg)
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
    def try_convert(klass, value)
      return nil unless klass

      if Union === klass
        klass.each do |k|
          t = try_convert(k, value)
          return t if !t.nil?
        end
        nil
      elsif ArrayOf === klass
        value.map { |v| try_convert(klass.type, v) }
      elsif klass.ancestors.include?(TypeStruct)
        klass.from_hash(value)
      elsif klass.ancestors.include?(Struct)
        struct = klass.new
        value.each { |k, v| struct[k] = v }
        struct
      else
        value
      end
    rescue
      nil
    end

    def from_hash(h)
      args = {}
      h.each do |key, value|
        t = type(key)
        if Class === t
          case
          when t.ancestors.include?(TypeStruct)
            args[key] = t.from_hash(value)
          when t.ancestors.include?(Struct)
            struct = t.new
            value.each { |k, v| struct[k] = v }
            args[key] = struct
          when t.respond_to?(:new)
            args[key] = t.new(value)
          else
            args[key] = value
          end
        elsif ArrayOf === t
          args[key] = if value.respond_to?(:map)
            value.map { |v| try_convert(t.type, v) }
          else
            value
          end
        else
          args[key] = try_convert(t, value)
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
      if ArrayOf === t && Array === v
        v.all? { |vv| t.type === vv }
      elsif Array === t
        return false if v.nil?
        v.all? { |i| t.any? { |c| c === i } }
      elsif TypeStruct === v
        t == v.class
      else
        t === v
      end
    end

    alias original_new new
    def new(**args)
      Class.new(TypeStruct) do
        const_set :DEFINITION, args

        class << self
          alias_method :new, :original_new
        end

        args.each do |k, _|
          define_method(k) do
            instance_variable_get("@#{k}")
          end

          define_method("#{k}=") do |v|
            raise TypeStruct::NoMemberError unless respond_to?(k)
            unless self.class.valid?(k, v)
              raise TypeError, "#{self.class}##{k} expect #{self.class.type(k)} got #{v.inspect}"
            end
            instance_variable_set("@#{k}", v)
          end
        end
      end
    end
  end
end
