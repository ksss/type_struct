class TypeStruct
  require "type_struct/union"
  require "type_struct/array_of"
  require "type_struct/interface"
  require "type_struct/version"

  def initialize(arg)
    sym_arg = {}
    arg.each do |k, v|
      sym_arg[k.to_sym] = v
    end
    self.class.members.each do |k|
      self[k] = sym_arg[k]
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
  alias to_s inspect

  def to_h
    m = {}
    self.class.members.each do |k|
      m[k] = self[k]
    end
    m
  end

  class << self
    def try_convert(klass, value)
      return nil unless !klass.nil? && !value.nil?
      if Union === klass
        klass.each do |k|
          t = begin
                try_convert(k, value)
              rescue TypeError
                nil
              end
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
      elsif klass === value
        value
      else
        nil
      end
    end

    def from_hash(h)
      args = {}
      h.each do |key, value|
        key = key.to_sym
        t = type(key)
        args[key] = try_convert(t, value)
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
      definition[k]
    end

    def valid?(k, v)
      definition[k] === v
    end

    alias original_new new
    def new(**args, &block)
      c = Class.new(TypeStruct) do
        const_set :DEFINITION, args

        class << self
          alias_method :new, :original_new
        end

        args.each do |k, _|
          define_method(k) do
            instance_variable_get("@#{k}")
          end

          define_method("#{k}=") do |v|
            unless self.class.valid?(k, v)
              raise TypeError, "#{self.class}##{k} expect #{self.class.type(k)} got #{v.inspect}"
            end
            instance_variable_set("@#{k}", v)
          end
        end
      end
      if block_given?
        c.module_eval(&block)
      end
      c
    end
  end
end
