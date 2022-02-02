class VirtualMachine
  def evaluate(input_instruction_pointer)
    call_frames << CallFrame.new(input_instruction_pointer.dup)
    result = nil
    while call_frames.any?
      instruction_pointer = call_frames.last.instruction_pointer
      opcode = instruction_pointer.next!
      case opcode
      when Opcodes::DISCARD
        pop!
      when Opcodes::RETURN
        call_frames.pop
        if call_frames.empty?
          result = pop!
        end

      when Opcodes::LOAD_CONSTANT
        push! instruction_pointer.next!
      when Opcodes::LOAD_LOCAL
        push! call_frames.last[instruction_pointer.next!]

      when Opcodes::JUMP
        call_frames.last.instruction_pointer = instruction_pointer.next!
      when Opcodes::JUMP_UNLESS_FALSE
        destination = instruction_pointer.next!
        call_frames.last.instruction_pointer = destination if pop!
      when Opcodes::CALL
        destination_instruction_pointer = instruction_pointer.next!
        arguments_count = instruction_pointer.next!
        call_frame = CallFrame.new(destination_instruction_pointer, arguments_count)
        argument_slots = []
        argument_values = []
        arguments_count.times do |index|
          argument_slots[index] = instruction_pointer.next!
          argument_values[arguments_count - index - 1] = pop!
        end
        pop!
        argument_slots.zip(argument_values).each do |slot, value|
          call_frame[slot] = value
        end
        call_frames << call_frame

      when Opcodes::INTEGER_ADD
        second_argument = pop!
        first_argument = pop!
        push!(first_argument + second_argument)
      when Opcodes::INTEGER_SUBTRACT
        second_argument = pop!
        first_argument = pop!
        push!(first_argument - second_argument)
      when Opcodes::INTEGER_LESS_THAN
        second_argument = pop!
        first_argument = pop!
        push!(first_argument < second_argument)
      when Opcodes::INTEGER_GREATER_THAN
        second_argument = pop!
        first_argument = pop!
        push!(first_argument > second_argument)
      else
        raise "unimplemented opcode: #{opcode}"
      end
    end

    raise "registers not empty after running bytecode: #{registers}" unless registers.empty?
    result
  end

  def push!(value)
    registers.push(value)
  end

  def pop!
    raise "attempted to pop from an empty registers" if registers.empty?
    registers.pop
  end

  def registers
    @registers ||= []
  end

  def call_frames
    @call_frames ||= []
  end
end
