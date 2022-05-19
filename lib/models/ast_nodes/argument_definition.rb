module AstNodes
  class ArgumentDefinition
    include BaseAstNode

    def self.match?(s_expression)
      s_expression.atom?
    end

    def name
      s_expression.text
    end
  end
end
