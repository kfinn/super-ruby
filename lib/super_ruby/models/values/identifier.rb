module SuperRuby
  module Values
    class Identifier
      def initialize(name)
        @name = name
      end
      attr_reader :name

      def ==(other)
        other.kind_of?(Identifier) && name == other.name
      end
      alias eql? ==

      def hash
        { name: name }.hash
      end

      def resolve_within(scope)
        expression = scope.resolve(self)
        expression.evaluate! scope
        expression.value.resolve_within scope
      end
    end
  end
end