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
      if message_send.argument_s_expressions.empty? && message_send.message == 'self'
        true
      elsif message_send.argument_s_expressions.empty? && message_send.message.in?(super_binding_value.dynamic_local_type_inferences)
        true
      elsif message_send.message.in?(super_binding_value.setter_names) && message_send.argument_s_expressions.size == 1
        true
      elsif message_send.message == 'let'
        if !message_send.argument_s_expressions.size.in?(2..3) || !message_send.argument_s_expressions.first.atom?
          raise "Invalid let: expected (let <name> <Type> [<initial  value>]), got (let #{message_send.argument_s_expressions.join(" ")})" 
        end
  
        super_binding_value.set_dynamic_type_inference( 
          message_send.argument_s_expressions.first.text,
          Jobs::TypeInferenceGivenByEvaluation.new(
            Jobs::StaticEvaluationTypeInference.new(
              AstNode.from_s_expression(
                message_send.argument_s_expressions.second
              )
            )
          ),
          mutable: true
        )

        true
      end
    end

    def message_send_result_type_inference(type_inference)
      if type_inference.message == 'self'
        job
      elsif type_inference.message == 'let'
        Jobs::LetTypeInference.new(
          type_inference,
          super_binding_value.fetch_dynamic_type_inference(
            type_inference.argument_s_expressions.first.text
          )
        )
      elsif type_inference.message.in?(super_binding_value.setter_names)
        Jobs::SetterCallTypeInference.new(
          super_binding_value.fetch_dynamic_type_inference(type_inference.message[0..-2]),
          Workspace.type_inference_for(type_inference.argument_s_expressions.first.ast_node)
        )
      elsif type_inference.message.in?(super_binding_value.dynamic_local_type_inferences)
        raise "Invalid define: expected 0 arguments, but got #{type_inference.argument_s_expressions.size}" unless type_inference.argument_s_expressions.size == 0
        super_binding_value.fetch_dynamic_type_inference(type_inference.message)
      else
        super
      end
    end

    def build_receiver_bytecode!(type_inference)
      Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_bytecode_builder << self
    end

    def build_message_send_bytecode!(type_inference)
      if type_inference.message == 'self'
      elsif type_inference.message == 'let'
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        if type_inference.result_type_inference.value_ast_node.present?
          type_inference.result_type_inference.value_ast_node.build_bytecode!(
            type_inference.result_type_inference.value_type_inference
          )
          Workspace.current_bytecode_builder << Opcodes::SET_LOCAL
          Workspace.current_bytecode_builder << super_binding_value.fetch_dynamic_slot_index(type_inference.argument_s_expressions.first.text)
        end
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << Types::Void.instance
      elsif type_inference.message.in?(super_binding_value.setter_names)
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        type_inference.result_type_inference.value_type_inference.ast_node.build_bytecode!(
          type_inference.result_type_inference.value_type_inference
        )
        slot_index = super_binding_value.fetch_dynamic_slot_index(type_inference.message[0..-2])
        Workspace.current_bytecode_builder << Opcodes::SET_LOCAL
        Workspace.current_bytecode_builder << slot_index
        Workspace.current_bytecode_builder << Opcodes::LOAD_LOCAL
        Workspace.current_bytecode_builder << slot_index
      elsif type_inference.message.in?(super_binding_value.dynamic_local_type_inferences)
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

    def let_names
      let_names ||= []
    end
  end
end
