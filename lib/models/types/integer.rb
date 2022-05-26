module Types
  class Integer
    include Singleton
    include BaseType

    def message_send_result_type_inference(type_inference)
      argument_type_inferences = Workspace.type_inferences_for(type_inference.argument_s_expressions.map(&:ast_node))
      case type_inference.message
      when '+', '-'
        raise "Invalid arguments count: expected 1, but got #{argument_type_inferences.size}" unless argument_type_inferences.size == 1
        BinaryOperatorTypeInference.new(*argument_type_inferences, self)
      when '>', '<', '=='
        raise "Invalid arguments count: expected 1, but got #{argument_type_inferences.size}" unless argument_type_inferences.size == 1
        BinaryOperatorTypeInference.new(*argument_type_inferences, Boolean.instance)
      else
        super
      end
    end

    def build_message_send_bytecode!(type_inference)
      case type_inference.message
      when '+', '-', '<', '>', '=='
        type_inference
          .argument_s_expressions
          .first
          .ast_node.build_bytecode!(
            type_inference
              .result_type_inference
              .argument_type_inference
          )
        
        Workspace.current_bytecode_builder <<
          case type_inference.message
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

    def build_llvm!
      'i64'
    end

    def build_message_send_llvm!(receiver_llvm_value, type_inference)
      case type_inference.message
      when '+', '-', '<', '>', '=='
        argument_llvm_value =
          type_inference
            .argument_s_expressions
            .first
            .ast_node
            .build_llvm!(
              type_inference
                .result_type_inference
                .argument_type_inference
            )
          
        Llvm::Register.create! do |register|
          Workspace.current_basic_block <<
            case type_inference.message
            when '+'
              "#{register.to_s} = add #{build_llvm!} #{receiver_llvm_value}, #{argument_llvm_value}"
            when '-'
              "#{register.to_s} = sub #{build_llvm!} #{receiver_llvm_value}, #{argument_llvm_value}"
            when '<'
              "#{register.to_s} = icmp slt #{build_llvm!} #{receiver_llvm_value}, #{argument_llvm_value}"
            when '>'
              "#{register.to_s} = icmp sgt #{build_llvm!} #{receiver_llvm_value}, #{argument_llvm_value}"
            when '=='
              "#{register.to_s} = icmp eq #{build_llvm!} #{receiver_llvm_value}, #{argument_llvm_value}"
            end
        end
      else
        super
      end
    end

    def build_static_value_llvm!(value)
      value
    end

    class BinaryOperatorTypeInference
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
      end
      attr_reader :argument_type_inference
      attr_accessor :added_downstreams, :argument_type_check, :validated, :valid, :errors
      alias complete? validated
      alias valid? valid

      def work!
        if !added_downstreams
          self.added_downstreams = true
          argument_type_inference.add_downstream self
        end
        return unless argument_type_inference.complete?
        if argument_type_check.nil?
          self.argument_type_check = argument_type_inference.type_check
          argument_type_check.add_downstream self
        end
        return unless argument_type_check.complete?
        self.validated = true
        self.valid = argument_type_inference.type == Integer.instance
        self.errors = argument_type_inference.type == Integer.instance ? [] : ["Expected: #{Integer.instance.to_s}, actual: #{argument_type_inference.type}"]
      end
    end
  end
end
