module AstNode
  PRIORITIZED_AST_NODE_CLASSES = [
    AstNodes::ImplicitSelfMessageSendThunk,
    AstNodes::ImplicitSelfMessageSend,
    AstNodes::Define,
    AstNodes::ProcedureDefinition,
    AstNodes::ConcreteProcedureLiteral,
    AstNodes::If,
    AstNodes::Sequence,
    AstNodes::MessageSend
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
