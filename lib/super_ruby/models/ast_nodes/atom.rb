module SuperRuby
  module AstNodes
    Atom = Struct.new(:token) do
      def self.from_tokens(tokens)
        new(tokens.next)
      end

      delegate :text, to: :token

      def value
        raise "attempting to take the value of an unevaluated expression" unless instance_variable_defined?(:@value)
        @value
      end

      def evaluate!(scope)
        @value = 
          if token.match.kind_of? TokenMatches::StringLiteral
            Values::Concrete.new(text[1..-2].gsub("\\\"", '"'))
          elsif /\A[0-9][0-9_]*\Z/.match? text
            Values::Concrete.new(text.to_i)
          elsif /\A[0-9][0-9_]*\.[0-9_]*\Z/.match? text
            Values::Concrete.new(text.to_f)
          else
            Values::Identifier.new(text)
          end
      end

      def is_define?
        token.match.kind_of?(TokenMatches::Symbol) && text == 'define'
      end
    end
  end
end
