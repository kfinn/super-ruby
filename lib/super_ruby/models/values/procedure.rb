module SuperRuby
  module Values
    class Procedure
      attr_reader :arguments, :body, :scope

      def initialize(arguments, body, scope=Scope::GlobalScope.instance)
        @arguments = arguments
        @body = body
        @scope = scope
      end

      def call!(argument_values, memory)
        raise 'invalid arguments' unless argument_values.size == arguments.size

        call_scope =
          arguments
          .zip(argument_values)
          .each_with_object(scope.spawn) do |(argument, argument_value), draft_scope|
            draft_scope.define! argument.text, argument_value
          end
        
          body.evaluate! call_scope, memory
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

        def evaluate!(scope, memory)
          evaluate_block.call(scope, memory)
        end
      end

      BUILTINS = {
        "+" => new(
          [
            BuiltinProcedureArgument.new("lhs"),
            BuiltinProcedureArgument.new("rhs")
          ],
          BuiltinProcedureBody.new do |scope, _memory|
            lhs = scope.resolve("lhs")
            rhs = scope.resolve("rhs")
            raise "Invalid +: mismatched types (#{lhs.type} + #{rhs.type})" unless lhs.type == rhs.type
            Concrete.new(
              lhs.type,
              lhs.value + rhs.value
            )
          end
        ),
        "-" => new(
          [
            BuiltinProcedureArgument.new("lhs"),
            BuiltinProcedureArgument.new("rhs")
          ],
          BuiltinProcedureBody.new do |scope, _memory|
            lhs = scope.resolve("lhs")
            rhs = scope.resolve("rhs")
            raise "Invalid -: mismatched types (#{lhs.type} - #{rhs.type})" unless lhs.type == rhs.type
            Concrete.new(
              lhs.type,
              lhs.value - rhs.value
            )
          end
        ),
        "==" => new(
          [
            BuiltinProcedureArgument.new("lhs"),
            BuiltinProcedureArgument.new("rhs")
          ],
          BuiltinProcedureBody.new do |scope, _memory|
            lhs = scope.resolve("lhs")
            rhs = scope.resolve("rhs")
            raise "Invalid ==: mismatched types (#{lhs.type} == #{rhs.type})" unless lhs.type == rhs.type
            Concrete.new(
              Type::INTEGER,
              lhs.type == rhs.type && lhs.value == rhs.value ? 1 : 0
            )
          end
        ),
        "size_of" => new(
          [
            BuiltinProcedureArgument.new("type")
          ],
          BuiltinProcedureBody.new do |scope, _memory|
            type = scope.resolve("type")
            raise "Invalid size_of: cannot find size of something that is not of type Type (#{type.type.to_s})" unless type.type == Type::TYPE
            Concrete.new(
              Type::INTEGER,
              type.value.size
            )
          end
        ),
        "allocate" => new(
          [
            BuiltinProcedureArgument.new("size")
          ],
          BuiltinProcedureBody.new do |scope, memory|
            size = scope.resolve("size")
            raise "Invalid allocate: size must have type Integer, given #{size.type}" unless size.type == Type::INTEGER
            allocation_id = memory.allocate(size.value)
            Concrete.new(
              Type::POINTER,
              allocation_id
            )
          end
        ),
        "free" => new(
          [BuiltinProcedureArgument.new("pointer")],
          BuiltinProcedureBody.new do |scope, memory|
            pointer = scope.resolve("pointer")
            raise "Invalid free: pointer must have type Pointer, given #{pointer.type}" unless pointer.type == Type::POINTER
            memory.free(pointer.value)
            Concrete.new(Type::VOID, nil)
          end
        ),
        "assign" => new(
          [
            BuiltinProcedureArgument.new("destination"),
            BuiltinProcedureArgument.new("value")
          ],
          BuiltinProcedureBody.new do |scope, memory|
            destination = scope.resolve("destination")
            value = scope.resolve("value")
            destination.assign! value
          end
        ),
        "dereference" => new(
          [BuiltinProcedureArgument.new("pointer")],
          BuiltinProcedureBody.new do |scope, memory|
            pointer = scope.resolve("pointer")
            raise "invalid dereference: pointer must have type Pointer, given #{pointer.type}" unless pointer.type == Type::POINTER
            memory.get(pointer.value)
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
