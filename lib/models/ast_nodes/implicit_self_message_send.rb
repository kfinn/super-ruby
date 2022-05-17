module AstNodes
  class ImplicitSelfMessageSend
    include BaseAstNode

    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.first.atom? &&
        Workspace.current_super_binding.super_respond_to?(s_expression.first.text)
      )
    end

    def spawn_type_inference
      receiver_type_inference = Workspace.current_super_binding.receiver_type_inference_for!(message)
      Jobs::MessageSendTypeInference.new(receiver_type_inference, message, argument_s_expressions)
    end

    def build_bytecode!(type_inference)
      Workspace.current_super_binding.build_receiver_bytecode_for!(type_inference.message)
    end

    def message
      s_expression.first.text
    end

    def argument_s_expressions
      @argument_s_expressions ||= s_expression[1..]
    end
  end
end
