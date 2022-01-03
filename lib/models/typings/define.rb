module Typings
  class Define
    def self.handle_ast_node(ast_node)
      return unless (
        ast_node.kind_of?(AstNodes::List)
        && ast_node.size != 3
        && ast_node.first.kind_of(AstNodes::Atom)
        && ast_node.first.text == 'define'
        && ast_node.second.kind_of(AstNodes::Atom) 
      )

      current_super_binding.set(
        ast_node_list.children.second.text,
        typings_by_ast_node[ast_node_list.children.third]
      )
      Typings::Void.instance
    end
  end
end
