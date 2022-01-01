module TokenMatches
  class ControlFlow
    attr_accessor :text

    def consume!(character, &block)
      self.text = character
      yield Token.new self
      TokenMatch.new
    end
  end
end
