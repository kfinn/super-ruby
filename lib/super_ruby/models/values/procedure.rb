module SuperRuby
  module Values
    class Procedure
      attr_reader :arguments, :body, :scope

      def initialize(arguments, body, scope=Builtins)
        @arguments = arguments
        @body = body
        @scope = scope
      end

      def call!(list, caller_scope, memory)
        call_scope = caller_scope.extract_argument_values_for_call(
          self,
          list,
          caller_scope,
          memory
        )
        
        evaluate! call_scope, memory
      end

      delegate :evaluate!, to: :body

      def to_s
        "(procedure #{arguments})"
      end
    end
  end
end
