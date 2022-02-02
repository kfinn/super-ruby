module AstNodes
  class ProcedureDefinition
    include BaseAstNode

    Argument = Struct.new(:s_expression) do
      def self.match?(s_expression)
        s_expression.atom?
      end

      def name
        s_expression.text
      end
    end

    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.size == 3 &&
        s_expression.first.atom? &&
        s_expression.first.text == 'procedure' &&
        s_expression.second.list? &&
        s_expression.second.all? { |argument_s_expression| Argument.match? argument_s_expression }
      )
    end

    def spawn_typing
      Jobs::ImmediateTyping.new(
        Types::AbstractProcedure.new(
          arguments_ast_nodes.map(&:name),
          body_ast_node
        )
      )
    end

    def evaluate_with_tree_walking(typing)
      typing.type.to_s
    end

    def build_bytecode!(typing)
      Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_workspace.current_bytecode_builder << typing.type.to_s
    end

    def arguments_ast_nodes
      @arguments_ast_nodes ||= s_expression.second.map do |argument_s_expression|
        Argument.new(argument_s_expression)
      end
    end

    def body_ast_node
      @body_ast_node ||= AstNode.from_s_expression(s_expression.third)
    end
  end
end
