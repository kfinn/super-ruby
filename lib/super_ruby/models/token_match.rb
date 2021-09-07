module SuperRuby
  class TokenMatch
    def consume!(character, &block)
      return self if character.is_super_whitespace?

      concrete_match_class =
        if character.is_super_identifier_start? 
          TokenMatches::Identifier
        elsif character.is_super_integer_literal_start?
          TokenMatches::IntegerLiteral
        elsif character.is_super_string_literal_terminator?
          TokenMatches::StringLiteral
        else
          TokenMatches::Punctuation
        end
      concrete_match_class.new.consume!(character, &block)
    end
  end
end
