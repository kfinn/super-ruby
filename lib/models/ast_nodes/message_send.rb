module AstNodes
  class MessageSend
    include BaseAstNode
    
    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.size >= 2 &&
        s_expression.second.atom?
      )
    end

    def spawn_type_inference
      Jobs::MessageSendTypeInference.new(self)
    end

    def build_bytecode!(type_inference)
      receiver_ast_node.build_bytecode! type_inference.receiver_type_inference
      type_inference.receiver_type_inference.type.build_message_send_bytecode! type_inference
    end

    def build_llvm!(type_inference)
      receiver_llvm_value = receiver_ast_node.build_llvm! type_inference.receiver_type_inference
      type_inference.receiver_type_inference.type.build_message_send_llvm! receiver_llvm_value, type_inference
    end

    def receiver_ast_node
      @receiver_ast_node ||= AstNode.from_s_expression(s_expression.first)
    end

    def message
      @message ||= s_expression.second.text
    end

    def argument_s_expressions
      @argument_s_expressions ||= s_expression[2..]
    end

    def receiver_type_inference
      @receiver_type_inference ||= Workspace.type_inference_for(receiver_ast_node)
    end
  end
end
