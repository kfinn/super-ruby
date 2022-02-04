class VirtualMachine
  def evaluate(input_instruction_pointer)
    call_frames << CallFrame.new(input_instruction_pointer.dup)
    result = nil
    while call_frames.any?
      if ENV['debug']
        puts "registers: [#{registers.map(&:to_s).join(",")}]"
        puts "instructions: #{upcoming_instructions.map(&:to_s).join(",")}"
      end
      opcode = next_instruction!

      case opcode
      when Opcodes::DISCARD
        pop!
      when Opcodes::RETURN
        call_frames.pop
        if call_frames.empty?
          result = pop!
        end

      when Opcodes::LOAD_CONSTANT
        push! next_instruction!
      when Opcodes::LOAD_LOCAL
        push! call_frames.last[next_instruction!]

      when Opcodes::JUMP
        call_frames.last.instruction_pointer = next_instruction!
      when Opcodes::JUMP_UNLESS_FALSE
        destination = next_instruction!
        call_frames.last.instruction_pointer = destination if pop!
      when Opcodes::CALL
        arguments_count = pop!
        argument_slots = []
        arguments_count.times do |index|
          argument_slots.unshift(pop!)
        end
        argument_values = []
        arguments_count.times do |index|
          argument_values.unshift(pop!)
        end

        destination_instruction_pointer = pop!
        call_frame = CallFrame.new(destination_instruction_pointer, arguments_count)
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

  def upcoming_instructions
    call_frames.last.instruction_pointer.preview
  end

  def next_instruction!
    current_call_frame = call_frames.last
    result = current_call_frame.instruction_pointer.dereference
    current_call_frame.instruction_pointer = current_call_frame.instruction_pointer.succ
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
