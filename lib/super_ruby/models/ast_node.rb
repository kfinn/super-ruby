module SuperRuby
  class AstNode
    AST_NODES_BY_PRIORITY = [
      AstNodes::BinaryOperatorApplication,
      AstNodes::Sequence,
      AstNodes::IntegerLiteral
    ]

    def self.from_tokens(tokens)
      expressions = []
      while !tokens.empty?
        AST_NODES_BY_PRIORITY.each do |ast_node_class|
          if ast_node_class.can_build_from_tokens? tokens
            expressions << ast_node_class.from_tokens(tokens)
            break;
          end
        end
      end
      
      if expressions.size == 1
        expressions.first
      else
        Sequence.new expressions: expressions
      end
    end
  end
end
