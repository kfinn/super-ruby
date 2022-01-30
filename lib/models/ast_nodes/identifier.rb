module AstNodes
  class Identifier
    include BaseAstNode

    def self.match?(s_expression)
      s_expression.atom?
    end

    def spawn_typing
      Workspace.current_workspace.current_super_binding.fetch_typing(s_expression.text)
    end
  end
end
