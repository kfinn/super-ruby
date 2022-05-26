module AstNodes
  class ImplicitSelfMessageSendThunk
    include BaseAstNode

    def self.match?(s_expression)
      (
        s_expression.atom? &&
        Workspace.current_super_binding.super_respond_to?(new(s_expression))
      )
    end

    def spawn_type_inference
      Jobs::MessageSendTypeInference.new(self)
    end

    def build_bytecode!(type_inference)
      Workspace.current_super_binding.build_receiver_bytecode_for!(type_inference)
      type_inference.receiver_type_inference.type.build_message_send_bytecode! type_inference
    end

    def build_llvm!(type_inference)
      receiver_llvm_value = Workspace.current_super_binding.build_receiver_llvm_for!(type_inference)
      type_inference.receiver_type_inference.type.build_message_send_llvm!(receiver_llvm_value, type_inference)
    end

    def message
      s_expression.text
    end

    def argument_s_expressions
      []
    end

    def receiver_type_inference
      @receiver_type_inference ||= Workspace.current_super_binding.receiver_type_inference_for!(self)
    end
  end
end
