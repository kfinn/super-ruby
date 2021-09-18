module SuperRuby
  module Values
    class Method
      attr_reader :arguments, :body, :scope

      def initialize(arguments, body, scope=Builtins)
        @arguments = arguments
        @body = body
        @scope = scope
      end

      def call!(super_self, list, caller_scope, memory)
        call_scope = caller_scope.extract_argument_values_for_procedure_call(
          self,
          list,
          caller_scope,
          memory
        )
        call_scope.define! "self", super_self
        evaluate! call_scope, memory
      end

      delegate :evaluate!, to: :body

      def to_s
        "(procedure #{arguments})"
      end
    end
  end
end
