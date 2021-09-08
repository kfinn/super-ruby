module SuperRuby
  module TokenMatches
    class ControlFlow
      attr_accessor :text

      def consume!(character, &block)
        self.text = character
        yield Token.new self
        TokenMatch.new
      end
    end

    class Indent < ControlFlow
      def self.matches_first_character?(character)
        character.super_indent?
      end
    end
    class Dedent < ControlFlow
      def self.matches_first_character?(character)
        character.super_dedent?
      end
    end
  end
end
