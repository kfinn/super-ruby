module Typing
  class << self
    AST_NODE_HANDLERS = [
      :handle_define,
      :handle_procedure_definition,
      :handle_message_send,
      :handle_integer_literal,
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
      return unless (
        ast_node.list? &&
        ast_node.size == 3 &&
        ast_node.first.atom? &&
        ast_node.first.text == 'define' &&
        ast_node.second.atom?
      )

      Workspace.current_workspace.current_super_binding.set(
        ast_node.children.second.text,
        Workspace.current_workspace.typing_for(ast_node.children.third)
      )
      Jobs::ImmediateTyping.new(Types::Void.instance)
    end

    def handle_procedure_definition(ast_node)
      return unless (
        ast_node.list? &&
        ast_node.size == 3 &&
        ast_node.first.atom? &&
        ast_node.first.text == 'procedure' &&
        ast_node.second.list? &&
        ast_node.second.all?(&:atom?)
      )

      Jobs::ImmediateTyping.new(Types::AbstractProcedure.new(
        ast_node.second.map(&:text),
        ast_node.third
      ))
    end

    def handle_message_send(ast_node)
      Jobs::MessageSend.handle_ast_node(ast_node)
    end

    def handle_integer_literal(ast_node)
      return unless (
        ast_node.atom? &&
        ast_node.text.match(/0|-?[1-9](\d)*/)
      )
      Jobs::ImmediateTyping.new(Types::Integer.instance)
    end

    def handle_identifier(ast_node)
      return unless ast_node.kind_of? AstNodes::Atom
      Workspace.current_workspace.current_super_binding.fetch(ast_node.text)
    end
  end
end
