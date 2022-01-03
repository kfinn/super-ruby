module Typings
  class ProcedureDefinition
    def self.handle_ast_node(ast_node)
      return unless (
        ast_node.kind_of?(AstNodes::List)
        && ast_node.size == 3
        && ast_node.first.kind_of?(AstNodes::Atom)
        && ast_node.first.text == 'procedure'
        && ast_node.second.kind_of?(AstNodes::List)
        && ast_node.second.all? { |argument| argument.kind_of? AstNodes::Atom }
        && ast_node.third.kind_of?(AstNodes::List)
      )

      new(
        ast_node.second.map(&:text),
        ast_node.third
      )
    end

    def initialize(argument_names, body)
      @argument_names = argument_names
      @body = body
      @super_binding = Workspace.current_workspace.current_super_binding
    end

    attr_reader :argument_names, :body, :super_binding

    def dependencies
      @dependencies ||= []
    end

    def complete?
      true
    end

    def type
      self
    end
  end
end
