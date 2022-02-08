module Types
  class Integer
    include Singleton

    def delivery_strategy_for_message(message)
      :dynamic
    end


    def message_send_result_typing(message, argument_typings)
      case message
      when '+', '-'
        raise "Invalid arguments count: expected 1, but got #{argument_typings.size}" unless argument_typings.size == 1
        BinaryOperatorTyping.new(*argument_typings, self)
      when '>', '<'
        raise "Invalid arguments count: expected 1, but got #{argument_typings.size}" unless argument_typings.size == 1
        BinaryOperatorTyping.new(*argument_typings, Boolean.instance)
      else
        raise "invalid message: #{message}"
      end
    end

    def build_message_send_bytecode!(typing)
      Workspace
        .current_workspace
        .current_bytecode_builder << case typing.message
          when '+'
            Opcodes::INTEGER_ADD
          when '-'
            Opcodes::INTEGER_SUBTRACT
          when '<'
            Opcodes::INTEGER_LESS_THAN
          when '>'
            Opcodes::INTEGER_GREATER_THAN
          end
    end

    def to_s
      "Integer"
    end

    class BinaryOperatorTyping
      prepend Jobs::BaseJob

      def initialize(argument_typing, return_type)
        @argument_typing = argument_typing
        @return_type = return_type
        @argument_typing.add_downstream(self)
      end
      attr_reader :argument_typing, :return_type
      alias type return_type
      delegate :complete?, to: :argument_typing

      def complete?
        worked? && argument_typing.complete?
      end

      def work!
        return unless argument_typing.complete?
        raise "invalid argument to +: expected Integer, got #{argument_typing.type}" unless argument_typing.type == Integer.instance
        @worked = true
      end

      def worked?
        @worked
      end
    end
  end
end
