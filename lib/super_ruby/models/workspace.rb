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
      within_workspace do
        expressions.last.value
      end
    end

    def within_workspace(&block)
      self.class.within_workspace(self, &block)
    end

    def self.current_workspace
      raise 'attempting to evaluate expressions without a current workspace' unless @current_workspace.present?
      @current_workspace
    end

    def self.within_workspace(workspace)
      previous_workspace = @current_workspace
      begin
        @current_workspace = workspace
        yield
      ensure
        @current_workspace = previous_workspace
      end
    end
  end
end
