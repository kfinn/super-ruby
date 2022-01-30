module Jobs
  class Evaluation
    prepend BaseJob

    def initialize(ast_node)
      @ast_node = ast_node
      @typing = Workspace.current_workspace.typing_for(ast_node)
      typing.add_downstream(self)
    end

    attr_reader :ast_node, :typing
    attr_accessor :evaluated, :value
    alias evaluated? evaluated

    def complete?
      evaluated?
    end

    def work!
      return unless typing.complete?
      evaluate!
    end

    def evaluate!
      self.evaluated = true

      AST_NODE_HANDLERS.each do |handler|
        result = send(handler)
        if result != nil
          self.value = result
          return
        end
      end

      raise "unimplemented: #{ast_node}"
    end

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

    def handle_define
      return unless ast_node.define? && typing.type == Types::Void.instance
      Types::Void.instance.instance
    end

    def handle_procedure_definition; end

    def handle_if; end

    def handle_sequence; end

    def handle_message_send; end

    def handle_integer_literal
      return unless ast_node.integer_literal? && typing.type == Types::Integer.instance
      ast_node.text.to_i
    end

    def handle_boolean_literal
      return unless ast_node.boolean_literal? && typing.type == Types::Boolean.instance
      ast_node.text == "true"
    end

    def handle_identifier
    end
  end
end
