module SuperRuby
  module TokenMatches
    class StringLiteral
      def self.matches_first_character?(character)
        character.super_string_literal_terimator?
      end

      def consume!(character, &block)
        text << character
        return self unless terminated?

        yield Token.new self
        TokenMatch.new
      end

      def terminated?
        return false if text.size <= 1
        return false if text.end_with? "\\#{text[0]}"
        return true if text.end_with? text[0]
        false
      end

      def text
        @text ||= ''
      end

      def flush!
        raise 'reached end of code with an unterminated string literal'
      end
    end
  end
end
