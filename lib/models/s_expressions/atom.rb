module SExpressions
  class Atom
    include BaseSExpression
    include DerivesEquality
    def initialize(token)
      @token = token
    end
    attr_reader :token
    alias state token
    
    def self.from_tokens(tokens)
      new(tokens.next)
    end

    delegate :text, to: :token

    def to_s(depth=0)
      text
    end

    def list?
      false
    end

    def atom?
      true
    end
  end
end
