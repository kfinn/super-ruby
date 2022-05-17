module SExpressions
  module BaseSExpression
    def ast_node
      @ast_node ||= AstNode.from_s_expression(self)
    end
  end
end
