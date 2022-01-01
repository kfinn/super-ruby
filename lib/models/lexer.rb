class Lexer
  def initialize(source)
    @source = source
  end

  attr_reader :source

  def each_token(&block)
    return enum_for(__method__) unless block_given?

    current_match = TokenMatch.new
    source.each_char do |character|
      current_match = current_match.consume! character, &block
    end
    current_match.flush! &block
  end
end
