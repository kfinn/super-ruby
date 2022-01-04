module AstNodes
  Atom = ::Struct.new(:token) do
    def self.from_tokens(tokens)
      new(tokens.next)
    end

    delegate :text, to: :token

    def to_s
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
