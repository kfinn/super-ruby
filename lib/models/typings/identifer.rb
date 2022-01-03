module Typings
  class Identifier
    def self.handle_ast_node(ast_node)
      return unless ast_node.kind_of? AstNodes::Atom
      Workspace.current_workspace.current_super_binding.fetch(ast_node_atom.text)
    end
  end
end
