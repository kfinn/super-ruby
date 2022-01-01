module TokenMatches
  class Indent < ControlFlow
    def self.matches_first_character?(character)
      character.super_indent?
    end
  end
end
