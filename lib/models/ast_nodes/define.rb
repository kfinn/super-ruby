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
      Workspace.current_workspace.current_super_binding.set_static_typing(
        s_expression.children.second.text,
        Jobs::Evaluation.new(value_ast_node)
      )
      Jobs::ImmediateTypeInference.new(Types::Void.instance)
    end

    def value_ast_node
      @value_ast_node ||= AstNode.from_s_expression(s_expression.third)
    end

    def build_bytecode!(_typing)
      Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_workspace.current_bytecode_builder << Types::Void.instance.instance
    end
  end
end
