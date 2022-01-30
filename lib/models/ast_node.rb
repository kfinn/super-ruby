module AstNode
  PRIORITIZED_AST_NODE_CLASSES = [
    AstNodes::Define,
    AstNodes::ProcedureDefinition,
    AstNodes::If,
    AstNodes::Sequence,
    AstNodes::MessageSend,
    AstNodes::IntegerLiteral,
    AstNodes::BooleanLiteral,
    AstNodes::Identifier    
  ]

  def self.from_s_expression(s_expression)
    PRIORITIZED_AST_NODE_CLASSES.each do |ast_node_class|
      if ast_node_class.match?(s_expression)
        return ast_node_class.new(s_expression)
      end
    end
    raise "unimplemented: #{s_expression}"
  end
end
