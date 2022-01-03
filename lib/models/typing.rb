class Typing
  class << self
    def current_typings_by_ast_node
      Workspace.current_workspace.typings_by_ast_node
    end

    def new_typings_by_ast_node
      Hash.new do |hash, ast_node|
        hash[ast_node] = Typing.from_ast_node(ast_node)
      end
    end

    def from_ast_node(ast_node)
      (
        Typings::Define.handle_ast_node(ast_node)
        || Typings::ProcedureDefinition.handle_ast_node(ast_node)
        || Typings::ProcedureCall.handle_ast_node(ast_node)
        || Typings::MessageSend.handle_ast_node(ast_node)
        || Typings::Integer.handle_ast_node(ast_node)
        || Typings::Identifier.handle_ast_node(ast_node)
        || raise "unimplemented: #{ast_node}"
      )
    end
  end
end
