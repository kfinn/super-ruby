module SExpression
  def self.from_tokens(tokens)
    children = []
    while !tokens.empty?
      token = tokens.peek
      case token.match
      when TokenMatches::Dedent
        break
      when TokenMatches::Indent
        children << SExpressions::List.from_tokens(tokens)
      else
        children << SExpressions::Atom.from_tokens(tokens)
      end
    end
    
    children
  end
end
