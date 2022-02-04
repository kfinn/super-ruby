module AstNodes
  module BaseAstNode
    def initialize(s_expression)
      @s_expression = s_expression
    end

    attr_reader :s_expression

    def evaluate(typing)
      starting_bytecode_builder = BufferBuilder.new
      Workspace.current_workspace.with_current_bytecode_builder(starting_bytecode_builder) do
        build_bytecode!(typing)
        Workspace.current_workspace.current_bytecode_builder << Opcodes::RETURN
      end
      Workspace.current_workspace.virtual_machine.evaluate(starting_bytecode_builder.pointer)
    end

    def build_bytecode!(typing)
      raise "unimplemented: #{s_expression}"
    end
  end
end
