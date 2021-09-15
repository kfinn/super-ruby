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
    end
  end
end
