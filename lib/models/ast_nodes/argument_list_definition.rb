module AstNodes
  class ArgumentListDefinition
    include BaseAstNode

    include Enumerable
    delegate :each, to: :argument_definitions

    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.all? do |child_s_expression|
          ArgumentDefinition.match? child_s_expression
        end
      )
    end

    def argument_definitions
      @argument_definitions ||= s_expression.map do |child_s_expression|
        ArgumentDefinition.new(child_s_expression)
      end
    end
  end
end
