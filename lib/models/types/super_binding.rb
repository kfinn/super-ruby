module Types
  class SuperBinding
    include BaseType
    include DerivesEquality

    def initialize(super_binding_value)
      @super_binding_value = super_binding_value
    end
    attr_reader :super_binding_value
    alias state super_binding_value

    def message_send_result_type_inference(message, argument_s_expressions)
      case message
      when 'define'
        raise "Invalid define: expected 2 arguments, but got #{argument_s_expressions.size}" unless argument_s_expressions.size == 2
        raise "Invalid define: first argument must be an identifier" unless argument_s_expressions.first.atom?
        value_type_inference = Jobs::StaticEvaluationTypeInference.new(argument_s_expressions.last.ast_node)
        Workspace.current_super_binding.set_static_type_inference(
          argument_s_expressions.first.text,
          value_type_inference
        )
        Jobs::DefineTypeInference.new(value_type_inference)
      else
        super
      end
    end

    def build_message_send_bytecode!(type_inference)
      case type_inference.message
      when 'define'
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << Types::Void.instance.instance  
      else
        super
      end
    end
  end
end
