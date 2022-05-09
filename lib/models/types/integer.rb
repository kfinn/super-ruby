module Types
  class Integer
    include Singleton
    include BaseType

    def message_send_result_type_inference(message, argument_ast_nodes)
      argument_type_inferences = Workspace.current_workspace.type_inferences_for(argument_ast_nodes)
      case message
      when '+', '-'
        raise "Invalid arguments count: expected 1, but got #{argument_type_inferences.size}" unless argument_type_inferences.size == 1
        BinaryOperatorTyping.new(*argument_type_inferences, self)
      when '>', '<', '=='
        raise "Invalid arguments count: expected 1, but got #{argument_type_inferences.size}" unless argument_type_inferences.size == 1
        BinaryOperatorTyping.new(*argument_type_inferences, Boolean.instance)
      else
        super
      end
    end

    def build_message_send_bytecode!(type_inference)
      case type_inference.message
      when '+', '-', '<', '>', '=='
        type_inference.argument_ast_nodes.first.build_bytecode! type_inference.result_type_inference.argument_type_inference
        
        Workspace
          .current_workspace
          .current_bytecode_builder << case type_inference.message
            when '+'
              Opcodes::INTEGER_ADD
            when '-'
              Opcodes::INTEGER_SUBTRACT
            when '<'
              Opcodes::INTEGER_LESS_THAN
            when '>'
              Opcodes::INTEGER_GREATER_THAN
            when '=='
              Opcodes::INTEGER_EQUAL
            end
      else
        super
      end
    end

    class BinaryOperatorTyping
      prepend Jobs::BaseJob

      def initialize(argument_type_inference, return_type)
        @argument_type_inference = argument_type_inference
        @return_type = return_type
      end
      attr_reader :argument_type_inference, :return_type
      alias type return_type

      def complete?
        true
      end

      def type_check
        @type_check ||= BinaryOperatorTypeCheck.new(argument_type_inference)
      end
    end

    class BinaryOperatorTypeCheck
      prepend Jobs::BaseJob

      def initialize(argument_type_inference)
        @argument_type_inference = argument_type_inference
        argument_type_inference.add_downstream self
      end
      attr_reader :argument_type_inference
      attr_accessor :argument_type_check, :validated, :valid
      alias complete? validated
      alias valid? valid

      def work!
        return unless argument_type_inference.complete?
        if argument_type_check.nil?
          self.argument_type_check = argument_type_inference.type_check
          argument_type_check.add_downstream self
        end
        return unless argument_type_check.complete?
        self.validated = true
        self.valid = argument_type_inference.type == Integer.instance
      end
    end
  end
end
