module AstNodes
  class ConcreteProcedureLiteral
    include BaseAstNode

    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.size == 3 &&
        s_expression.first.atom? &&
        s_expression.first.text == 'ConcreteProcedure' &&
        s_expression.size == 3 &&
        s_expression.second.list?
      )
    end

    def spawn_typing
      Jobs::ConcreteProcedureLiteralTypedEvaluation.new(
        argument_ast_nodes.map do |argument_ast_node|
          Jobs::TypedEvaluation.new(argument_ast_node)
        end,
        Jobs::TypedEvaluation.new(return_ast_node)
      )
    end

    def build_bytecode!(typing)
      Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_workspace.current_bytecode_builder << typing.value
    end

    def argument_ast_nodes
      @argument_ast_nodes ||= s_expression.second.map do |argument_s_expression|
        AstNode.from_s_expression(argument_s_expression)
      end
    end

    def return_ast_node
      @return_ast_node ||= AstNode.from_s_expression(s_expression.third)
    end
  end
end
