require 'pathname'

class TypeStruct
  require "type_struct/union"
  require "type_struct/type_of"
  require "type_struct/array_of"
  require "type_struct/hash_of"
  require "type_struct/interface"
  require "type_struct/exceptions"
  require "type_struct/version"

  def initialize(arg = {})
    unless h = Hash.try_convert(arg)
      raise TypeError, "no implicit conversion from #{arg} to Hash"
    end
    sym_h = {}
    h.each do |k, v|
      sym_h[k.to_sym] = v
    end
    errors = []
    klass = self.class
    klass.members.each do |k|
      unless klass.valid?(k, sym_h[k])
        begin
          raise TypeError, "#{klass}##{k} expect #{klass.type(k)} got #{sym_h[k].inspect}"
        rescue TypeError => e
          errors << e
        end
      end
      instance_variable_set("@#{k}", sym_h[k])
    end
    raise MultiTypeError, errors unless errors.empty?
  end

  def ==(other)
    return false unless TypeStruct === other
    to_h == other.to_h
  end

  def []=(k, v)
    __send__ "#{k}=", v
  end

  def [](k)
    __send__ k
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

  module ClassMethods
    def from_hash(h)
      unless Hash === h
        h = h.to_hash if h.respond_to?(:to_hash)
        unless Hash === h
          raise TypeError, "#{self}.from_hash only accept Hash got `#{h.class}'"
        end
      end
      args = {}
      errors = []
      h.each do |key, value|
        key = key.to_sym
        t = type(key)
        args[key] = try_convert(t, key, value, errors)
      end
      raise MultiTypeError, errors unless errors.empty?
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
  end

  private

  class << self
    def try_convert(klass, key, value, errors)
      case klass
      when Union
        union_errors = []
        klass.each do |k|
          begin
            return try_convert(k, key, value, nil)
          rescue TypeError, MultiTypeError => e
            union_errors << e
          end
        end

        raise UnionNotFoundError, "#{klass} is not found with value `#{value}'\nerrors:\n#{union_errors.join("\n")}"
      when TypeOf
        klass.try_convert(key, value, errors)
      else
        if klass.respond_to?(:ancestors)
          if klass.ancestors.include?(TypeStruct)
            klass.from_hash(value)
          elsif klass.ancestors.include?(Struct)
            struct = klass.new
            value.each { |k, v| struct[k] = v }
            struct
          elsif klass === value
            value
          else
            begin
              raise TypeError, "#{self}##{key} expect #{klass} got #{value.inspect}"
            rescue => e
              raise unless errors
              errors << e
            end
            value
          end
        else
          value
        end
      end
    end
  end

  class << self
    alias original_new new
    def new(**args, &block)
      c = Class.new(TypeStruct) do
        extend ClassMethods
        const_set :DEFINITION, args.freeze

        class << self
          alias_method :new, :original_new
        end

        args.each_key do |k|
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
