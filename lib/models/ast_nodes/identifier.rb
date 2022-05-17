module AstNodes
  class Identifier
    include BaseAstNode

    def self.match?(s_expression)
      s_expression.atom?
    end

    def spawn_type_inference
      puts "searching for type_inference for #{name} within #{Workspace.current_super_binding.to_s}" if ENV['DEBUG']
      Workspace.current_super_binding.fetch_type_inference(name)
    end

    def build_bytecode!(type_inference)
      current_super_binding = Workspace.current_super_binding
      if current_super_binding.has_dynamic_binding? name
        Workspace.current_bytecode_builder << Opcodes::LOAD_LOCAL
        Workspace.current_bytecode_builder << current_super_binding.fetch_dynamic_slot_index(name)
      elsif current_super_binding.has_static_binding? name
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << Workspace.current_super_binding.fetch_static_type_inference(name).value
      else
        raise "unknown identifier: #{name}"
      end
    end
    
    def name
      s_expression.text
    end
  end
end
