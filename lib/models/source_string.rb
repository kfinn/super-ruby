class SourceString
  def initialize(text)
    @text = text
  end

  attr_reader :text
  delegate :each_char, to: :text
end
