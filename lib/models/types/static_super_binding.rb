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
      if message_send.argument_s_expressions.empty? && super_binding_value.has_static_binding?(message_send.message)
        true
      elsif message_send.message == 'define'
        if !message_send.argument_s_expressions.size == 2 || !message_send.argument_s_expressions.first.atom?
          raise "Invalid define: expected (define <name> <value>), got (define #{message_send.argument_s_expressions.join(" ")})" 
        end
  
        super_binding_value.set_static_type_inference( 
          message_send.argument_s_expressions.first.text,
          Jobs::StaticEvaluationTypeInference.new(
            message_send.argument_s_expressions.second.ast_node
          )
        )

        true
      end
    end

    def message_send_result_type_inference(type_inference)
      if type_inference.message == 'define'
        Jobs::DefineTypeInference.new(
          super_binding_value.fetch_static_type_inference(
            type_inference.argument_s_expressions.first.text
          )
        )
      elsif super_binding_value.has_static_binding?(type_inference.message)
        super_binding_value.static_locals[type_inference.message]
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
      if type_inference.message == 'define'
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << Types::Void.instance.instance  
      elsif super_binding_value.has_static_binding?(type_inference.message)
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << super_binding_value.fetch_static_type_inference(type_inference.message).value
      else
        super
      end
    end

    def build_message_send_llvm!(receiver_llvm_value, type_inference)
      if type_inference.message == 'define'
      elsif super_binding_value.has_static_binding?(type_inference.message)
        super_binding_value.fetch_static_type_inference(type_inference.message).build_static_value_llvm!
      else
        super
      end
    end

    def job
      @job ||= Jobs::ImmediateEvaluation.new(self, super_binding_value)
    end

    def to_s
      '<static super binding>'
    end
  end
end
