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

    def spawn_typing
      workspace = Workspace.current_workspace

      receiver_typing = workspace.typing_for(receiver_ast_node)
      Jobs::MessageSendTyping.new(receiver_typing, message, argument_ast_nodes)
    end

    def build_bytecode!(typing)
      argument_ast_nodes.zip(typing.argument_typings).map do |argument_ast_node, argument_typing|
        argument_ast_node.build_bytecode!(argument_typing)
      end

      receiver_ast_node.build_bytecode!(typing.receiver_typing)
      
      typing.receiver_typing.type.build_message_send_bytecode!(typing)
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
