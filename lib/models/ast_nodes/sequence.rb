module AstNodes
  class Sequence
    include BaseAstNode

    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.first.atom? &&
        s_expression.first.text == 'sequence' &&
        s_expression.second.list?
      )
    end

    def spawn_typing
      Workspace
        .current_workspace
        .with_current_super_binding(
          Workspace
            .current_workspace
            .current_super_binding
            .spawn(inherit_dynamic_locals: true)
        ) do
          child_typings = child_ast_nodes.map do |child_ast_node|
            Workspace.current_workspace.typing_for(child_ast_node)
          end
          child_typings.last
        end
    end

    def child_ast_nodes
      @child_ast_nodes ||= s_expression.second.map do |child_s_expression|
        AstNode.from_s_expression(child_s_expression)
      end
    end
  end
end
