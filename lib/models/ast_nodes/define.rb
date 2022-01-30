module AstNodes
  class Define
    include BaseAstNode
    
    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.size == 3 &&
        s_expression.first.atom? &&
        s_expression.first.text == 'define' &&
        s_expression.second.atom?
      )
    end

    def spawn_typing
      Workspace.current_workspace.current_super_binding.set_typing(
        s_expression.children.second.text,
        Workspace.current_workspace.typing_for(value_ast_node)
      )
      Jobs::ImmediateTyping.new(Types::Void.instance)
    end

    def value_ast_node
      @value_ast_node ||= AstNode.from_s_expression(s_expression.third)
    end

    def evaluate(typing)
      Types::Void.instance.instance
    end
  end
end
