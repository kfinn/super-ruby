module AstNodes
  class Let
    include BaseAstNode

    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.size.in?([3, 4]) &&
        s_expression.first.atom? &&
        s_expression.first.text == 'let' &&
        s_expression.second.atom?
      )
    end

    def name
      @name ||= s_expression.second.text
    end

    def type_ast_node
      @type_ast_node ||= AstNode.from_s_expression(s_expression.third)
    end

    def value_ast_node
      @value_ast_node ||= s_expression.fourth.present? && AstNode.from_s_expression(s_expression.fourth)
    end

    def spawn_type_inference
      type_inference = Jobs::LetTypeInference.new(self)
      Workspace.current_workspace.current_super_binding.set_dynamic_type_inference(
        name,
        type_inference.type_type_inference
      )
      type_inference
    end

    def build_bytecode!(type_inference)
      if value_ast_node.present?
        value_ast_node.build_bytecode!(type_inference.value_type_inference)
        Workspace.current_workspace.current_bytecode_builder << Opcodes::SET_LOCAL
        Workspace.current_workspace.current_bytecode_builder << Workspace.current_workspace.current_super_binding.fetch_dynamic_slot_index(name)
      end

      Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_workspace.current_bytecode_builder << Types::Void.instance
    end
  end
end
