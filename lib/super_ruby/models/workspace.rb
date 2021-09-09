module SuperRuby
  class Workspace
    attr_reader :source
    def initialize(source)
      @source = source
    end

    def expressions
      @expressions ||= AstNode.from_tokens(Lexer.new(source).each_token)
    end

    def evaluate
      expressions.each { |expression| expression.evaluate!(root_scope) }
      expressions.last.value.resolve_within(root_scope)
    end

    def root_scope
      @root_scope ||= Scope.new
    end
  end
end
