module Types
  class StaticSuperBinding
    include BaseType
    include DerivesEquality

    def initialize(super_binding_value)
      @super_binding_value = super_binding_value
    end
    attr_reader :super_binding_value
    alias state super_binding_value

    def super_respond_to?(message_send)
      message_send.argument_s_expressions.empty? && super_binding_value.has_static_binding?(message_send.message)
    end

    def message_send_result_type_inference(type_inference)
      if super_binding_value.has_static_binding?(type_inference.message)
        raise "Invalid define: expected 0 arguments, but got #{type_inference.argument_s_expressions.size}" unless type_inference.argument_s_expressions.size == 0
        super_binding_value.static_locals[type_inference.message]
      else
        super
      end

      # when 'define'
      #   raise "Invalid define: expected 2 arguments, but got #{type_inference.argument_s_expressions.size}" unless type_inference.argument_s_expressions.size == 2
      #   raise "Invalid define: first argument must be an identifier" unless type_inference.argument_s_expressions.first.atom?
      #   value_type_inference = Jobs::StaticEvaluationTypeInference.new(type_inference.argument_s_expressions.last.ast_node)
      #   Workspace.current_super_binding.set_static_type_inference(
      #     type_inference.argument_s_expressions.first.text,
      #     value_type_inference
      #   )
      #   Jobs::DefineTypeInference.new(value_type_inference)
    end

    def build_receiver_bytecode!(type_inference)
      Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_bytecode_builder << self
    end

    def build_message_send_bytecode!(type_inference)
      if super_binding_value.has_static_binding?(type_inference.message)
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << super_binding_value.fetch_static_type_inference(type_inference.message).value
      else
        super
      end
      # when 'define'
      #   Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      #   Workspace.current_bytecode_builder << Types::Void.instance.instance  
    end

    def job
      @job ||= Jobs::ImmediateEvaluation.new(self, super_binding_value)
    end

    def to_s
      '<static super binding>'
    end
  end
end
