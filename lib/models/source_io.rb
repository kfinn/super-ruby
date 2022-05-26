class SourceIo
  def initialize(io)
    @io = io
  end
  
  attr_reader :io
  delegate :each_char, to: :io
end
