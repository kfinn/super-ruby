module SuperRuby
  class IntegerLiteralTokenMatch
    def consume!(character, &block)
      if character.is_super_dot?
        IntegerLiteralFollowedByDotTokenMatch.new(before_dot_text: text)
      elsif !character.is_super_integer_literal?
        yield Token.new text: text, match: self
        TokenMatch.new.consume! character, &block
      else
        text << character
        self
      end
    end

    def text
      @text ||= ""
    end
  end
end
