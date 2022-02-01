module AstNodes
  class Identifier
    include BaseAstNode

    def self.match?(s_expression)
      s_expression.atom?
    end

    def spawn_typing
      Workspace.current_workspace.current_super_binding.fetch_typing(s_expression.text)
    end

    def evaluate_with_tree_walking(typing)
      Workspace.current_workspace.current_super_binding.fetch_value(s_expression.text)
    end

    def build_bytecode!(typing)
      Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_workspace.current_bytecode_builder << Workspace.current_workspace.current_super_binding.fetch_value(s_expression.text)
    end
  end
end
