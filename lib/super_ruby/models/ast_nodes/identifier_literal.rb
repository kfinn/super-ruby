module SuperRuby
  module AstNodes
    class Idenfitier
      def self.can_build_from_tokens?(tokens)
        tokens.peek.match.kind_of? TokenMatches::Identifier
      end

      def self.build_from_tokens(tokens)
        new token: tokens.next
      end

      include ActiveModel::Model
      attr_accessor :token
      delegate :text, to: :token
    end
  end
end
