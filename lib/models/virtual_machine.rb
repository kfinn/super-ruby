class VirtualMachine
  def evaluate(input_instruction_pointer)
    instruction_pointer = input_instruction_pointer.dup
    result = nil
    running = true
    while running
      opcode = instruction_pointer.next!
      case opcode
      when Opcodes::RETURN
        result = pop!
        running = false
      when Opcodes::LOAD_CONSTANT
        push! instruction_pointer.next!
      when Opcodes::DISCARD
        pop!
      else
        raise "unimplemented opcode: #{opcode}"
      end
    end

    raise "stack not empty after running bytecode: #{stack}" unless stack.empty?
    result
  end

  def push!(value)
    stack.push(value)
  end

  def pop!
    raise "attempted to pop from an empty stack" if stack.empty?
    stack.pop
  end

  def stack
    @stack ||= []
  end
end
