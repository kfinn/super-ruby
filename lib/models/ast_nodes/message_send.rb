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
      workspace = Workspace.current_workspace

      receiver_type_inference = workspace.type_inference_for(receiver_ast_node)
      Jobs::MessageSendTypeInference.new(receiver_type_inference, message, argument_ast_nodes)
    end

    def build_bytecode!(type_inference)
      argument_ast_nodes.zip(type_inference.argument_type_inferences).map do |argument_ast_node, argument_type_inference|
        argument_ast_node.build_bytecode!(argument_type_inference)
      end

      receiver_ast_node.build_bytecode!(type_inference.receiver_type_inference)
      
      type_inference.receiver_type_inference.type.build_message_send_bytecode!(type_inference)
    end

    def receiver_ast_node
      @receiver_ast_node ||= AstNode.from_s_expression(s_expression.first)
    end

    def message
      @message ||= s_expression.second.text
    end

    def argument_ast_nodes
      @argument_ast_nodes ||= s_expression[2..].map do |argument_s_expression|
        AstNode.from_s_expression(argument_s_expression)
      end
    end
  end
end
