class Typing
  def self.new_typings_by_ast_node
    Hash.new do |hash, ast_node|
      hash[ast_node] = Typing.from_ast_node(ast_node, hash)
    end
  end

  def self.from_ast_node(ast_node, typings_by_ast_node)
    case ast_node
    when AstNodes::List
      Typings::MessageSend.new(
        typings_by_ast_node[ast_node.children.first],
        ast_node.children.second,
        ast_node.children[2..].map { |argument_ast_node| typings_by_ast_node[argument_ast_node] }
      )
    when AstNodes::Atom
      case ast_node.text
      when /0|-?[1-9](\d)*/
        Typings::Integer.instance
      else
        raise 'unimplemented'
      end
    else
      raise 'unimplemented'
    end
  end
end
