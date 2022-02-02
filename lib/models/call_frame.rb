class CallFrame
  def initialize(instruction_pointer, size=0)
    @instruction_pointer = instruction_pointer
    @slots = Array.new(size)
  end
  attr_accessor :instruction_pointer, :slots
  delegate :[], :[]=, to: :slots
end
