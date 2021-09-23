module SuperRuby
  class Workspace
    attr_reader :source
    def initialize(source)
      @source = source
    end

    def root_ast_node
      unless instance_variable_defined?(:@root_ast_node)
        all_ast_nodes = AstNode.from_tokens(Lexer.new(source).each_token)
        raise 'attempted to evaluate multiple ast nodes at once' unless all_ast_nodes.size == 1
        @root_ast_node = all_ast_nodes.first
      end
      @root_ast_node
    end

    def evaluate!(expected_type=LLVM::Int)
      main_function = llvm_module.functions.add(
        BytecodeSymbolId.next("workspace"),
        [],
        expected_type
      ) do |main|
        main.basic_blocks.append.build do |main_basic_block|
          result = root_ast_node.to_bytecode_chunk! root_scope, llvm_module, main_basic_block
          main_basic_block.ret result.llvm_symbol
        end
      end
      engine = LLVM::JITCompiler.new(llvm_module)
      engine.run_function(main_function)
    end

    def root_scope
      @root_scope ||= Scope.new
    end

    def memory
      @memory ||= Memory.new
    end

    def llvm_module
      @llvm_module ||= LLVM::Module.new('workspace')
    end
  end
end
