module AstNodes
  class IntegerLiteral
    include BaseAstNode

    def self.match?(s_expression)
      (
        s_expression.atom? &&
        s_expression.text.match(/^(0|-?[1-9](\d)*)$/)
      )
    end

    def spawn_typing
      Jobs::ImmediateTyping.new(Types::Integer.instance)
    end

    def evaluate(typing)
      s_expression.text.to_i
    end
  end
end
