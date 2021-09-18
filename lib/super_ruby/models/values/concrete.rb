module SuperRuby
  module Values
    class Concrete
      attr_reader :type, :value

      def initialize(type, value)
        @type = type
        @value = value
      end

      def ==(other)
        other.kind_of?(Concrete) && to_attributes == other.to_attributes
      end
      alias eql? ==
      delegate :hash, to: :to_attributes

      def to_attributes
        { type: type, value: value }
      end

      def to_s
        "(#{type} #{value})"
      end

      def super_send!(list, scope, memory)
        if type == Builtins::Types::Macro.instance
          return value.call! list, scope, memory
        end

        method = list.second.evaluate! type.scope, memory
        method.value.call! self, list, scope, memory
      end
    end
  end
end
