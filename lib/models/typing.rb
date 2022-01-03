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
      case ast_node
      when AstNodes::List
        from_ast_node_list(ast_node)
      when AstNodes::Atom
        from_ast_node_atom(ast_node)
      else
        raise 'unimplemented'
      end
    end

    def from_ast_node_list(ast_node_list)
      typings_by_ast_node = current_typings_by_ast_node
      current_super_binding = Workspace.current_workspace.current_super_binding
      if ast_node_list.define?
        current_super_binding.set(
          ast_node_list.children.second.text,
          typings_by_ast_node[ast_node_list.children.third]
        )
        Typings::Void.instance
      else
        Typings::MessageSend.new(
          typings_by_ast_node[ast_node_list.children.first],
          ast_node_list.children.second,
          ast_node_list.children[2..].map { |argument_ast_node| typings_by_ast_node[argument_ast_node] }
        )
      end
    end

    def from_ast_node_atom(ast_node_atom)
      case ast_node_atom.text
      when /0|-?[1-9](\d)*/
        Typings::Integer.instance
      else
        Workspace.current_workspace.current_super_binding.fetch(ast_node_atom.text)
      end
    end
  end
end
