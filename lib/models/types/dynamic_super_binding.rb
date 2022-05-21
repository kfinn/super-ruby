module Types
  class DynamicSuperBinding
    include BaseType
    include DerivesEquality

    def initialize(super_binding_value)
      @super_binding_value = super_binding_value
    end
    attr_reader :super_binding_value
    alias state super_binding_value

    def super_respond_to?(message_send)
      message_send.argument_s_expressions.empty? && message_send.message.in?(super_binding_value.dynamic_local_type_inferences)
    end

    def message_send_result_type_inference(type_inference)
      if type_inference.message.in?(super_binding_value.dynamic_local_type_inferences)
        raise "Invalid define: expected 0 arguments, but got #{type_inference.argument_s_expressions.size}" unless type_inference.argument_s_expressions.size == 0
        super_binding_value.dynamic_local_type_inferences[type_inference.message]
      else
        super
      end
    end

    def build_receiver_bytecode!(type_inference)
      Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_bytecode_builder << self
    end

    def build_message_send_bytecode!(type_inference)
      if type_inference.message.in?(super_binding_value.dynamic_local_type_inferences)
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_LOCAL
        Workspace.current_bytecode_builder << super_binding_value.fetch_dynamic_slot_index(type_inference.message)
      else
        super
      end
    end

    def job
      @job ||= Jobs::ImmediateEvaluation.new(self, super_binding_value)
    end

    def to_s
      '<dynamic super binding>'
    end
  end
end
