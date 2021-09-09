module SuperRuby
  module Values
    class Concrete
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def resolve_within(_scope)
        self
      end

      def to_keyword
        nil
      end
    end
  end
end
