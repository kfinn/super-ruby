module AstNodes
  module BaseAstNode
    def initialize(s_expression)
      @s_expression = s_expression
    end

    attr_reader :s_expression

    def evaluate(typing)
      raise "unimplemented: #{s_expression}"
    end
  end
end
