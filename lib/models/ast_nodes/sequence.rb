module AstNodes
  class Sequence
    include BaseAstNode

    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.first.atom? &&
        s_expression.first.text == 'sequence' &&
        s_expression.second.list?
      )
    end

    def spawn_type_inference
      Jobs::SequenceTypeInference.new(self)
    end

    def build_bytecode!(type_inference)
      Workspace.with_current_super_binding(type_inference.children_super_binding) do
        children_with_type_inferences = child_ast_nodes.zip(type_inference.child_type_inferences)
        children_with_type_inferences[0..-2].each do |child_ast_node, child_type_inference|
          child_ast_node.build_bytecode!(child_type_inference)
          Workspace.current_bytecode_builder << Opcodes::DISCARD
        end
        children_with_type_inferences.last.tap do |last_child_ast_node, last_child_type_inference|
          last_child_ast_node.build_bytecode!(last_child_type_inference)
        end
      end
    end

    def child_ast_nodes
      @child_ast_nodes ||= s_expression.second.map do |child_s_expression|
        AstNode.from_s_expression(child_s_expression)
      end
    end
  end
end
