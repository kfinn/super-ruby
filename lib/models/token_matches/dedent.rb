module TokenMatches
  class Dedent < ControlFlow
    def self.matches_first_character?(character)
      character.super_dedent?
    end
  end
end
