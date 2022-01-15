module Typing
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
    ].freeze

    def from_ast_node(ast_node)
      AST_NODE_HANDLERS.each do |handler|
        typing = send(handler, ast_node)
        return typing if typing.present?
      end
      raise "unimplemented: #{ast_node}"
    end

    def handle_define(ast_node)
      return unless ast_node.define?

      Workspace.current_workspace.current_super_binding.set_typing(
        ast_node.children.second.text,
        Workspace.current_workspace.typing_for(ast_node.children.third)
      )
      Jobs::ImmediateTyping.new(Types::Void.instance)
    end

    def handle_procedure_definition(ast_node)
      return unless ast_node.procedure_definition?

      Jobs::ImmediateTyping.new(Types::AbstractProcedure.new(
        ast_node.second.map(&:text),
        ast_node.third
      ))
    end

    def handle_message_send(ast_node)
      return unless ast_node.message_send?
      Jobs::MessageSend.handle_ast_node(ast_node)
    end

    def handle_integer_literal(ast_node)
      return unless ast_node.integer_literal?
      Jobs::ImmediateTyping.new(Types::Integer.instance)
    end

    def handle_boolean_literal(ast_node)
      return unless ast_node.boolean_literal?
      Jobs::ImmediateTyping.new(Types::Boolean.instance)
    end

    def handle_if(ast_node)
      return unless ast_node.if?
      Jobs::IfTyping.handle_ast_node(ast_node)
    end

    def handle_sequence(ast_node)
      return unless ast_node.sequence?

      Workspace
        .current_workspace
        .with_current_super_binding(
          Workspace
            .current_workspace
            .current_super_binding
            .spawn(inherit_dynamic_locals: true)
        ) do
          child_typings = ast_node.second.map do |child_ast_node|
            Workspace.current_workspace.typing_for(child_ast_node)
          end
          child_typings.last
        end
    end

    def handle_identifier(ast_node)
      return unless ast_node.atom?
      Workspace.current_workspace.current_super_binding.fetch_typing(ast_node.text)
    end
  end
end
