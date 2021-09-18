module SuperRuby
  module Values
    class Procedure
      attr_reader :arguments, :body, :scope

      def initialize(arguments, body, scope=Builtins)
        @arguments = arguments
        @body = body
        @scope = scope
      end

      def call!(scope, memory)
        body.evaluate! scope, memory
      end

      def to_s
        "(procedure #{arguments})"
      end
    end
  end
end
