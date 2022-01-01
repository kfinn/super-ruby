module TokenMatches
  class Symbol
    def self.matches_first_character?(_character)
      true
    end

    def consume!(character, &block)
      if character.super_whitespace? || character.super_control_flow?
        yield Token.new self
        TokenMatch.new.consume! character, &block
      else
        text << character
        self
      end
    end

    def flush!
      yield Token.new self
    end

    def text
      @text ||= ''
    end
  end
end
