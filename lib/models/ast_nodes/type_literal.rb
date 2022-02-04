module AstNodes
  class TypeLiteral
    include BaseAstNode

    TYPES_BY_NAME = {
      "Integer" => Types::Integer.instance,
      "Boolean" => Types::Boolean.instance,
      "Void" => Types::Void.instance,
      "Type" => Types::Type.instance
    }

    def self.match?(s_expression)
      (
        s_expression.atom? &&
        s_expression.text.in?(TYPES_BY_NAME.keys)
      )
    end

    def spawn_typing
      Jobs::ImmediateTyping.new(Types::Type.instance)
    end

    def build_bytecode!(_typing)
      Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_workspace.current_bytecode_builder << TYPES_BY_NAME[s_expression.text]
    end
  end
end
