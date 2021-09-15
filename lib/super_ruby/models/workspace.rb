module SuperRuby
  class Workspace
    attr_reader :source
    def initialize(source)
      @source = source
    end

    def root_ast_node
      unless instance_variable_defined?(:@root_ast_node)
        all_ast_nodes = AstNode.from_tokens(Lexer.new(source).each_token)
        raise 'attempted to evaluate multiple ast nodes at once' unless all_ast_nodes.size == 1
        @root_ast_node = all_ast_nodes.first
      end
      @root_ast_node
    end

    def evaluate!
      root_ast_node.evaluate! root_scope, memory
    end

    def root_scope
      @root_scope ||= Scope.new
    end

    def memory
      @memory ||= Memory.new
    end
  end
end
