module AstNodes
  class Identifier
    include BaseAstNode

    def self.match?(s_expression)
      s_expression.atom?
    end

    def spawn_typing
      Workspace.current_workspace.current_super_binding.fetch_typing(name)
    end

    def evaluate_with_tree_walking(typing)
      Workspace.current_workspace.current_super_binding.fetch_value(name)
    end

    def build_bytecode!(typing)
      current_workspace = Workspace.current_workspace
      current_super_binding = current_workspace.current_super_binding
      if current_super_binding.has_dynamic_binding? name
        Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_LOCAL
        Workspace.current_workspace.current_bytecode_builder << current_super_binding.fetch_dynamic_slot_index(name)
      elsif current_super_binding.has_static_binding? name
        Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_workspace.current_bytecode_builder << Workspace.current_workspace.current_super_binding.fetch_static_typing(name).value
      else
        raise "unknown identifier: #{name}"
      end
    end
    
    def name
      s_expression.text
    end
  end
end
