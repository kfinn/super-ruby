module SuperRuby
  module AstNodes
    class IntegerLiteral
      def self.can_build_from_tokens?(tokens)
        tokens.peek.match.kind_of? TokenMatches::IntegerLiteral
      end

      def self.from_tokens(tokens)
        next_token = tokens.next
        puts next_token
        new token: next_token
      end

      include ActiveModel::Model
      attr_accessor :token
      delegate :text, to: :token
    end
  end
end
