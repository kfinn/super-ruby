module SuperRuby
  class AstNode
    def self.from_tokens(tokens)
      children = []
      while !tokens.empty?
        token = tokens.peek
        case token.match
        when TokenMatches::Dedent
          break
        when TokenMatches::Indent
          children << AstNodes::List.from_tokens(tokens)
        else
          children << AstNodes::Atom.from_tokens(tokens)
        end
      end
      
      children
    end
  end
end
