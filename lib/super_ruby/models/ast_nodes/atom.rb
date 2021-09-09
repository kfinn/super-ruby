module SuperRuby
  module AstNodes
    Atom = Struct.new(:token) do
      def self.from_tokens(tokens)
        new(tokens.next)
      end

      delegate :text, to: :token

      def value
        evaluate! unless instance_variable_defined?(:@value)
        @value
      end

      def evaluate!
        @value = 
          if token.match.kind_of? TokenMatches::StringLiteral
            text[1..-2].gsub("\\\"", '"')
          elsif /\A[0-9][0-9_]*\Z/.match? text
            text.to_i
          elsif /\A[0-9][0-9_]*\.[0-9_]*\Z/.match? text
            text.to_f
          else
            workspace.resolve_identifier text
          end
      end
    end
  end
end
