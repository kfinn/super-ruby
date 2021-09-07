module SuperRuby
  module TokenMatches
    class IntegerLiteralFollowedByDotAndWhitespace
      include ActiveModel::Model
      attr_accessor :before_dot_text

      def consume!(character, &block)
        if character.is_super_whitespace?
          self
        elsif character.is_super_integer_literal?
          raise "could not parse Integer literal followed by dot and whitespace #{before_dot_text}. #{character}"
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
    end
  end
end
