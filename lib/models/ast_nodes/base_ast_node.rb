module AstNodes
  module BaseAstNode
    def initialize(s_expression)
      @s_expression = s_expression
    end

    attr_reader :s_expression
    delegate :to_s, to: :s_expression

    def evaluate(type_inference)
      puts "evaluating #{s_expression}" if ENV["DEBUG"]
      starting_bytecode_builder = BufferBuilder.new
      Workspace.with_current_bytecode_builder(starting_bytecode_builder) do
        build_bytecode!(type_inference)
        Workspace.current_bytecode_builder << Opcodes::RETURN
      end
      Workspace.evaluate(starting_bytecode_builder.pointer)
    end

    def build_bytecode!(type_inference)
      raise "unimplemented: #{s_expression}"
    end

    def build_llvm!(type_inference)
      raise "unimplemented: #{s_expression} (#{self.class.to_s})"
    end
  end
end
