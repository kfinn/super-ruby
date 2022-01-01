class Receiver
  def initialize(parent = nil)
    @parent = parent
  end
  attr_reader :parent
end
