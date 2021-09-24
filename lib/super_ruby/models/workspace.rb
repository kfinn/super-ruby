module SuperRuby
  class Workspace
    class << self
      def current_workspace
        raise unless @current_workspace.present?
        @current_workspace
      end

      def with_current_workspace(current_workspace)
        previous_workspace = @current_workspace
        @current_workspace = current_workspace
        yield
      ensure
        @current_workspace = previous_workspace
      end

      delegate :current_basic_block_builder, :current_basic_block_builder=, :with_current_basic_block_builder, to: :current_workspace

      def current_llvm_module
        current_workspace.llvm_module
      end
    end

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
      main_function = Scope.with_current_scope(root_scope) do
        self.class.with_current_workspace(self) do
          llvm_module.functions.add(
            BytecodeSymbolId.next("workspace"),
            [],
            expected_type
          ) do |main|
            main.basic_blocks.append.build do |main_basic_block|
              self.current_basic_block_builder = main_basic_block
              result = root_ast_node.to_bytecode_chunk!
              main_basic_block.ret result.llvm_symbol
            end
          end
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

    attr_accessor :current_basic_block_builder

    def with_current_basic_block_builder(current_basic_block_builder)
      previous_basic_block_builder = self.current_basic_block_builder
      self.current_basic_block_builder = current_basic_block_builder
      yield
    ensure
      self.current_basic_block_builder = previous_basic_block_builder
    end
  end
end
