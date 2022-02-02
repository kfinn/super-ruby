module AstNodes
  class BooleanLiteral
    include BaseAstNode

    def self.match?(s_expression)
      (
        s_expression.atom? &&
        s_expression.text.in?(['true', 'false'])
      )
    end

    def spawn_typing
      Jobs::ImmediateTyping.new(Types::Boolean.instance)
    end

    def build_bytecode!(_typing)
      Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_workspace.current_bytecode_builder << (s_expression.text == 'true')
    end
  end
end
