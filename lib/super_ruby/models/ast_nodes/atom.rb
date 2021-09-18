module SuperRuby
  module AstNodes
    Atom = Struct.new(:token) do
      def self.from_tokens(tokens)
        new(tokens.next)
      end

      delegate :text, to: :token

      def evaluate!(scope, memory)
        if token.match.kind_of? TokenMatches::StringLiteral
          Values::Concrete.new(Builtins::Types::String.instance, text[1..-2].gsub("\\\"", '"'))
        elsif /\A[0-9][0-9_]*\Z/.match? text
          Values::Concrete.new(Builtins::Types::Integer.instance, text.to_i)
        elsif /\A[0-9][0-9_]*\.[0-9_]*\Z/.match? text
          Values::Concrete.new(Builtins::Types::Float.instance, text.to_f)
        else
          scope.resolve(text)
        end
      end

      def to_s
        text
      end
    end
  end
end
