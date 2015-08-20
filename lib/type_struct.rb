class TypeStruct
  require "type_struct/version"

  class NoMemberError < StandardError
  end

  class << self
    def new(**args)
      Class.new do
        attr_accessor *args.keys
        const_set :MEMBERS, args

        class << self
          def members
            const_get(:MEMBERS)
          end

          def type(k)
            members[k]
          end

          def valid?(k, v)
            type(k) === v
          end
        end

        def initialize(**arg)
          self.class.members.each do |k, _|
            self[k] = arg[k]
          end
        end

        def []=(k, v)
          raise TypeStruct::NoMemberError unless respond_to?(k)
          unless self.class.valid?(k, v)
            raise TypeError, "expect #{self.class.type(k)} got #{v.class}"
          end
          __send__("#{k}=", v)
        end

        def [](k)
          raise TypeStruct::NoMemberError unless respond_to?(k)
          __send__(k)
        end

        def inspect
          m = to_h.map do |k, v|
            "#{k}=#{v.inspect}"
          end
          "#<#{self.class.to_s} #{m.join(', ')}>"
        end

        def to_h
          m = {}
          self.class.members.each do |k, _|
            m[k] = self[k]
          end
          m
        end
        alias to_hash to_h
      end
    end
  end
end
