module SuperRuby
  module AstNodes
    class Sequence
      include ActiveModel::Model
      attr_accessor :expressions

      def self.can_build_from_tokens?(tokens)
        false
      end

      def self.from_tokens(tokens)
        raise 'nope'
      end
    end
  end
end
