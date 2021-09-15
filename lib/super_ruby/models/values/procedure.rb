module SuperRuby
  module Values
    class Procedure
      attr_reader :arguments, :body

      def initialize(arguments, body)
        @arguments = arguments
        @body = body
      end

      def call!(argument_values)
        raise 'invalid arguments' unless argument_values.size == arguments.size

        scope =
          arguments
          .zip(argument_values)
          .each_with_object(Scope.new) do |(argument, argument_value), draft_scope|
            draft_scope.define! argument.text, argument_value
          end
        
          body.evaluate! scope
      end

      class BuiltinProcedureArgument
        attr_reader :name

        def initialize(name)
          @name = name
        end

        alias text name
      end

      class BuiltinProcedureBody
        attr_reader :evaluate_block

        def initialize(&evaluate_block)
          @evaluate_block = evaluate_block
        end

        def evaluate!(scope)
          evaluate_block.call(scope)
        end
      end

      BUILTINS = {
        "+" => new(
          [
            BuiltinProcedureArgument.new("lhs"),
            BuiltinProcedureArgument.new("rhs")
          ],
          BuiltinProcedureBody.new do |scope|
            lhs = scope.resolve("lhs")
            rhs = scope.resolve("rhs")
            raise "Invalid +: mismatched types (#{lhs.type} + #{rhs.type})" unless lhs.type == rhs.type
            Concrete.new(
              lhs.type,
              lhs.value + rhs.value
            )
          end
        )
      }.freeze
      def self.builtins
        BUILTINS
      end

      def to_s
        "(procedure #{arguments})"
      end
    end
  end
end
