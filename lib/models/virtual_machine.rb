class VirtualMachine
  def evaluate(input_instruction_pointer)
    call_frames << CallFrame.new(input_instruction_pointer.dup)
    result = nil
    while call_frames.any?
      if ENV['DEBUG']
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
        call_frames.last.instruction_pointer = pop!
      when Opcodes::JUMP_UNLESS_FALSE
        destination = pop!
        condition = pop!
        call_frames.last.instruction_pointer = destination if condition
      when Opcodes::CALL
        arguments_count = next_instruction!
        destination_instruction_pointer = pop!
        argument_values = []
        arguments_count.times do |index|
          argument_values.unshift(pop!)
        end

        call_frame = CallFrame.new(destination_instruction_pointer, arguments_count)
        argument_values.each_with_index do |value, slot|
          call_frame[slot] = value
        end
        call_frames << call_frame

      when Opcodes::INTEGER_ADD
        first_argument = pop!
        second_argument = pop!
        push!(first_argument + second_argument)
      when Opcodes::INTEGER_SUBTRACT
        first_argument = pop!
        second_argument = pop!
        push!(first_argument - second_argument)
      when Opcodes::INTEGER_LESS_THAN
        first_argument = pop!
        second_argument = pop!
        push!(first_argument < second_argument)
      when Opcodes::INTEGER_GREATER_THAN
        first_argument = pop!
        second_argument = pop!
        push!(first_argument > second_argument)
      when Opcodes::INTEGER_EQUAL
        first_argument = pop!
        second_argument = pop!
        push!(first_argument == second_argument)
      else
        raise "unimplemented opcode: #{opcode}"
      end
    end

    raise "registers not empty after running bytecode: #{registers.map(&:to_s)}" unless registers.empty?
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
