module Jobs
  class Compilation
    prepend BaseJob

    def initialize(output)
      @output = output
    end
    attr_reader :output
    attr_accessor :main_procedure_type_inference, :main_procedure_type_check, :complete
    alias complete? complete

    def work!
      if main_procedure_type_inference.nil?
        raise "no main procedure defined" unless Workspace.current_super_binding.has_static_binding? 'main'
        self.main_procedure_type_inference = Workspace.current_super_binding.fetch_static_type_inference('main')
        main_procedure_type_inference.add_downstream self
      end
      return unless main_procedure_type_inference.complete?

      if main_procedure_type_check.nil?
        self.main_procedure_type_check = main_procedure_type_inference.type_check
        main_procedure_type_check.add_downstream self
      end
      return unless main_procedure_type_check.complete?

      raise "main procedure failed typecheck" unless main_procedure_type_check.valid? && main_procedure_type_inference.type == Types::ConcreteProcedure.new([], Types::Integer.instance)
      
      main_procedure_llvm_function = 
        as_current_compilation do
          main_procedure_type_check.result_type_inference.concrete_procedure_instance.llvm_function
        end

      globals <<  '@.output_format_string = private unnamed_addr constant [4 x i8] c"%d\0A\00"'
      globals << 'declare i32 @printf(i8* nocapture, ...) nounwind'
      globals << <<~LLVM
        define i32 @main() {
          %cast_output_format_string = getelementptr [4 x i8],[4 x i8]* @.output_format_string, i64 0, i64 0
          %super_main_result = call i64 @#{main_procedure_llvm_function.name}()
          call i32 (i8*, ...) @printf(i8* %cast_output_format_string, i64 %super_main_result)
          ret i32 0
        }
      LLVM

      globals.each do |global|
        output << "#{global.to_s}\n"
      end

      self.complete = true
    end

    def create_function!(concrete_procedure)
      Llvm::Function.new(concrete_procedure).tap do |function|
        globals << function
      end
    end

    def globals
      @globals ||= []
    end

    def declared?(ast_node)
      ast_node.in? declared_ast_nodes
    end

    def declare_ast_node!(ast_node)
      declared_ast_nodes << ast_node
    end

    def declared_ast_nodes
      @declared_ast_nodes ||= Set.new
    end

    def as_current_compilation
      Workspace.with_current_compilation(self) { yield }
    end

    attr_accessor :current_basic_block
    def with_current_basic_block(basic_block)
      previous_basic_block = current_basic_block
      self.current_basic_block = basic_block
      yield
    ensure
      self.current_basic_block = previous_basic_block
    end

    def current_function
      current_basic_block&.function
    end
  end
end
