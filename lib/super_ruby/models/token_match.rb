module SuperRuby
  class TokenMatch
    def consume!(character, &block)
      return self if character.is_super_whitespace?


      concrete_match_klass =
        if character.is_super_identifier_start? 
          IdentifierTokenMatch
        elsif character.is_super_integer_literal_start?
          IntegerLiteralTokenMatch
        elsif character.is_super_string_literal_terminator?
          StringLiteralTokenMatch
        else
          PunctuationTokenMatch
        end
      concrete_match_klass.new.consume!(character, &block)
    end
  end
end
