module AstNodes
  class If
    include BaseAstNode

    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.first.atom? &&
        s_expression.first.text == 'if' &&
        s_expression.size.in?(3..4)
      )
    end

    def spawn_typing
      workspace = Workspace.current_workspace

      condition_typing = workspace.typing_for(condition_ast_node)

      then_branch_typing =
        workspace
        .with_current_super_binding(
          workspace
          .current_super_binding
          .spawn(inherit_dynamic_locals: true)
        ) do
          workspace.typing_for(then_branch_ast_node)
        end

      else_branch_typing = 
        if else_branch_ast_node.present?
          workspace
          .with_current_super_binding(
            workspace
            .current_super_binding
            .spawn(inherit_dynamic_locals: true)
          ) do
            workspace.typing_for(else_branch_ast_node)
          end
        else
          Jobs::ImmediateTyping.new(Types::Void.instance)
        end

      Jobs::IfTyping.new(
        condition_typing,
        then_branch_typing,
        else_branch_typing
      )
    end

    def evaluate_with_tree_walking(typing)
      if condition_ast_node.evaluate_with_tree_walking(typing.condition_typing)
        then_branch_ast_node.evaluate_with_tree_walking(typing.then_branch_typing)
      elsif else_branch_ast_node.present?
        else_branch_ast_node.evaluate_with_tree_walking(typing.else_branch_typing)
      else
        Types::Void.instance.instance
      end
    end

    def condition_ast_node
      @condition_ast_node ||= AstNode.from_s_expression(s_expression.second)
    end

    def then_branch_ast_node
      @then_branch_ast_node ||= AstNode.from_s_expression(s_expression.third)
    end

    def else_branch_ast_node
      unless instance_variable_defined?(:@else_branch_ast_node)
        @else_branch_ast_node = 
          if s_expression.size == 4
            AstNode.from_s_expression(s_expression.fourth)
          end
      end
      @else_branch_ast_node
    end
  end
end
