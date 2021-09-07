module SuperRuby
  class IdentifierTokenMatch
    def consume!(character, &block)
      if character.is_super_wordbreak?
        yield Token.new text: text, match: self
        TokenMatch.new.consume!(character, &block)
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
