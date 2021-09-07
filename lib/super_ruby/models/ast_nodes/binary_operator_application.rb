module SuperRuby
  module AstNodes
    class BinaryOperatorApplication
      def self.can_build_from_tokens?(tokens)
        false
      end

      def self.from_tokens(tokens)
        lhs = IntegerLiteral.from_tokens(tokens)
      end

      include ActiveModel::Model
      attr_accessor :operands, :operators
    end
  end
end
