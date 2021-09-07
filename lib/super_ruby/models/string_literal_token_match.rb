module SuperRuby
  class StringLiteralTokenMatch
    def consume!(character,  &block)
      text << character
      if terminated?
        yield Token.new text: text, match: self
        TokenMatch.new
      else
        self
      end
    end

    def terminated?
      return false if text.size <= 1
      return false if text.end_with? "\\#{text[0]}"
      return true if text.end_with? text[0]
      false
    end

    def text
      @text ||= ""
    end
  end
end
