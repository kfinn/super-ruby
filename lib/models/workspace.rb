class Workspace
  class << self
    attr_accessor :current_workspace

    def with_current_workspace(workspace)
      previous_workspace = self.current_workspace
      self.current_workspace = workspace
      yield
    ensure
      self.current_workspace = previous_workspace
    end

    delegate(
      :current_super_binding,
      :with_current_super_binding,
      :current_bytecode_builder,
      :current_bytecode_builder=,
      :with_current_bytecode_builder,
      :virtual_machine,
      :type_inference_for,
      :type_inferences_for,
      :work_queue,
      :with_current_compilation,
      :current_compilation,
      to: :current_workspace
    )

    delegate(
      :evaluate,
      to: :virtual_machine
    )

    delegate(
      :current_basic_block,
      :with_current_basic_block,
      :previous_value_register,
      to: :current_compilation
    )
  end

  def add_source_string(text)
    add_source SourceString.new(text)
  end

  def add_source(source)
    sources_awaiting_static_pass << source
  end

  def process_sources_awaiting_static_pass!
    last_s_expression = nil
    as_current_workspace do
      sources_awaiting_static_pass.each do |source|
        root_s_expressions = SExpression.from_tokens(Lexer.new(source).each_token)
        root_s_expressions.each do |root_s_expression|
          type_inference_for(root_s_expression.ast_node)
        end
        last_s_expression = root_s_expressions.last
      end
    end
    sources_awaiting_static_pass.clear
    last_s_expression
  end

  def evaluate!
    as_current_workspace do
      result_s_expression = process_sources_awaiting_static_pass!
      self.result = Jobs::Evaluation.new(result_s_expression.ast_node).tap(&:enqueue!)
      work_queue.pump! while (result.incomplete? && work_queue.any?)
    end
  end

  def compile!(output=$stdout)
    as_current_workspace do
      process_sources_awaiting_static_pass!
      raise 'no main procedure defined' unless global_super_binding.has_static_binding? 'main'
      
      sources_awaiting_static_pass.each do |source|
        root_s_expressions = SExpression.from_tokens(Lexer.new(source).each_token)
        root_s_expressions.each do |root_s_expression|
          type_inference_for(root_s_expression.ast_node)
        end
      end
      sources_awaiting_static_pass.clear
      compilation = Jobs::Compilation.new(output).tap(&:enqueue!)
      work_queue.pump! while compilation.incomplete?
    end
  end

  attr_accessor :result
  delegate :type, :value, to: :result, prefix: true

  def current_super_binding
    @current_super_binding ||= global_super_binding
  end

  def as_current_workspace
    self.class.with_current_workspace(self) { yield }
  end

  attr_writer :current_super_binding

  def with_current_super_binding(new_super_binding)
    previous_super_binding = self.current_super_binding
    self.current_super_binding = new_super_binding
    yield
  ensure
    self.current_super_binding = previous_super_binding
  end

  delegate :type_inference_for, :type_inferences_for, to: :type_inferences

  def global_super_binding
    @global_super_binding ||= RootSuperBinding.instance.spawn
  end

  def work_queue
    @work_queue ||= WorkQueue.new
  end

  attr_accessor :current_bytecode_builder

  def with_current_bytecode_builder(bytecode_builder)
    previous_bytecode_builder = current_bytecode_builder
    self.current_bytecode_builder = bytecode_builder
    yield
  ensure
    self.current_bytecode_builder = previous_bytecode_builder
  end

  def virtual_machine
    @virtual_machine ||= VirtualMachine.new
  end

  attr_accessor :current_compilation

  def with_current_compilation(compilation)
    previous_compilation = current_compilation
    self.current_compilation = compilation
    yield
  ensure
    self.current_compilation = previous_compilation
  end

  private
  
  def sources_awaiting_static_pass
    @sources_awaiting_static_pass ||= []
  end

  def type_inferences
    @type_inferences ||= TypeInferencesCollection.new(self)
  end
end
