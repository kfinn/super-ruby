module Evaluation
  class << self
    AST_NODE_HANDLERS = [
      :handle_define,
      :handle_procedure_definition,
      :handle_if,
      :handle_sequence,
      :handle_message_send,
      :handle_integer_literal,
      :handle_boolean_literal,
      :handle_identifier
    ]

    def from_ast_node(ast_node)
      AST_NODE_HANDLERS.each do |handler|
        typing = send(handler, ast_node)
        return typing if typing.present?
      end
      raise "unimplemented: #{ast_node}"
    end

    def handle_define(ast_node)
    end

    def handle_procedure_definition(ast_node)
    end

    def handle_if(ast_node)
    end

    def handle_sequence(ast_node)
    end

    def handle_message_send(ast_node)
    end

    def handle_integer_literal(ast_node)
      return unless ast_node.integer_literal?

      workspace.current_basic_block << 
    end

    def handle_boolean_literal(ast_node)
    end

    def handle_identifier(ast_node)
    end
  end
end
