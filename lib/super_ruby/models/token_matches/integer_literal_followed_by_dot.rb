module SuperRuby
  module TokenMatches
    class IntegerLiteralFollowedByDot
      include ActiveModel::Model
      attr_accessor :before_dot_text, :integer_literal_match

      def consume!(character, &block)
        if character.is_super_whitespace?
          IntegerLiteralFollowedByDotAndWhitespace.new(before_dot_text: before_dot_text)
        elsif character.is_super_integer_literal?
          FloatLiteral.new(before_decimal_point_text: before_dot_text).consume! character, &block
        elsif character.is_super_identifier_start?
          yield Token.new(text: before_dot_text, match: integer_literal_match)
          yield Token.new(text: ".", match: self)
          TokenMatch.new.consume! character, &block
        elsif character.is_super_punctuation?
          FloatLiteral.new(before_decimal_point_text: before_dot_text).consume! character, &block
        else
          raise "could not parse Integer literal followed by dot #{before_dot_text}.#{character}"
        end
      end

      def encountered_whitespace!
        @encountered_whitespace = true
      end

      def encountered_whitespace?
        unless instance_variable_defined?(:@encountered_whitespace)
          @encountered_whitespace = false
        end
        @encountered_whitespace
      end
    end
  end
end
