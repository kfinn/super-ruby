module SuperRuby
  class TokenMatch
    def consume!(character, &block)
      return self if character.super_whitespace?

      concrete_match_class =
        [
          TokenMatches::Indent,
          TokenMatches::Dedent,
          TokenMatches::StringLiteral,
          TokenMatches::Symbol
        ].find do |match_class|
          match_class.matches_first_character? character
        end
      concrete_match_class.new.consume!(character, &block)
    end

    def flush!; end
  end
end
