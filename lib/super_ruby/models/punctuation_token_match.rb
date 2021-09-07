module SuperRuby
  class PunctuationTokenMatch
    def consume!(character, &block)
      if character.is_super_wordbreak_punctuation?
        if text.present?
          yield Token.new(text: text, match: self) 
          PunctuationTokenMatch.new.consume! character, &block
        else
          text << character
          yield Token.new(text: text, match: self)
          TokenMatch.new
        end
      elsif character.is_super_whitespace? || character.is_super_identifier_start? || character.is_super_integer_literal_start?
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
