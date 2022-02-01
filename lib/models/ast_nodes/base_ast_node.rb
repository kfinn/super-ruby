module AstNodes
  module BaseAstNode
    def initialize(s_expression)
      @s_expression = s_expression
    end

    attr_reader :s_expression

    def evaluate_with_tree_walking(typing)
      raise "unimplemented: #{s_expression}"
    end

    def evaluate_with_bytecode(typing)
      bytecode_builder = BufferBuilder.new
      Workspace.current_workspace.with_current_bytecode_builder(bytecode_builder) do
        build_bytecode!(typing)
      end
      bytecode_builder << Opcodes::RETURN
      Workspace.current_workspace.virtual_machine.evaluate(bytecode_builder.build.pointer)
    end

    def build_bytecode!(typing)
      raise "unimplemented: #{s_expression}"
    end
  end
end
