module SuperRuby
  module TokenMatches
    class FloatLiteral
      include ActiveModel::Model
      attr_accessor :before_decimal_point_text

      def consume!(character, &block)
        if character.is_super_integer_literal?
          after_decimal_point_text << character
          self
        else
          yield Token.new text: "#{before_decimal_point_text}.#{after_decimal_point_text}", match: self
          TokenMatch.new.consume! character, &block
        end
      end

      def after_decimal_point_text
        @after_decimal_point_text ||= ""
      end
    end
  end
end
