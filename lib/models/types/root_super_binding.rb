module Types
  class RootSuperBinding
    INTEGER_LITERAL_REGEXP = /^(0|-?[1-9](\d)*)$/

    include BaseType
    include DerivesEquality

    def initialize(super_binding_value)
      @super_binding_value = super_binding_value
    end
    attr_reader :super_binding_value
    alias state super_binding_value

    def super_respond_to?(message_send)
      (
        message_send.argument_s_expressions.empty? &&
        (
          message_send.message.in?([
            'Integer', 'Boolean', 'Void', 'Type', 'true', 'false'
          ]) ||
          message_send.message.match?(INTEGER_LITERAL_REGEXP)
        )
      )
    end

    def message_send_result_type_inference(type_inference)
      case type_inference.message
      when 'Integer', 'Boolean', 'Void', 'Type'
        raise "Invalid define: expected 0 arguments, but got #{type_inference.argument_s_expressions.size}" unless type_inference.argument_s_expressions.size == 0
        Jobs::ImmediateTypeInference.new(Types::Type.instance)
      when 'true', 'false'
        raise "Invalid define: expected 0 arguments, but got #{type_inference.argument_s_expressions.size}" unless type_inference.argument_s_expressions.size == 0
        Jobs::ImmediateTypeInference.new(Types::Boolean.instance)
      when INTEGER_LITERAL_REGEXP
        raise "Invalid define: expected 0 arguments, but got #{type_inference.argument_s_expressions.size}" unless type_inference.argument_s_expressions.size == 0
        Jobs::ImmediateTypeInference.new(Types::Integer.instance)
      else
        super
      end
    end

    def build_receiver_bytecode!(type_inference)
      Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_bytecode_builder << self
    end

    def build_receiver_llvm!(type_inference); end

    def build_message_send_bytecode!(type_inference)
      case type_inference.message
      when 'Integer'
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << Types::Integer.instance
      when 'Boolean'
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << Types::Boolean.instance
      when 'Void'
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << Types::Void.instance
      when 'Type'
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << Types::Type.instance
      when /^(0|-?[1-9](\d)*)$/
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << type_inference.message.to_i
      when 'true', 'false'
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << (type_inference.message == 'true')  
      else
        super
      end
    end

    def build_message_send_llvm!(receiver_llvm_value, type_inference)
      case type_inference.message
      when /^(0|-?[1-9](\d)*)$/
        "#{type_inference.message}"
      else
        super
      end
    end

    def job
      @job ||= Jobs::ImmediateEvaluation.new(self, super_binding_value)
    end

    def to_s
      '<root super binding>'
    end
  end
end
