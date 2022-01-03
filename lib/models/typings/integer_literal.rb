module Typings
  class IntegerLiteral
    include Singleton

    def self.handle_ast_node(ast_node)
      return unless (
        ast_node.kind_of?(AstNodes::Atom)
        && ast_node.text.match(/0|-?[1-9](\d)*/)
      )

      self
    end

    def dependencies
      @dependencies ||= []
    end

    def complete?
      true
    end

    def type
      Types::Integer.instance
    end
  end
end
