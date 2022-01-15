class BasicBlock
  def bytecode
    @bytecode ||= []
  end

  def <<(*instructions)
    instructions.each { |instruction| bytecode << instruction }
  end
end
