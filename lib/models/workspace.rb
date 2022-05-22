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
      to: :current_workspace
    )

    delegate(
      :evaluate,
      to: :virtual_machine
    )
  end

  def add_source_string(text)
    sources_awaiting_static_pass << SourceString.new(text)
  end

  def evaluate!
    self.class.with_current_workspace(self) do
      sources_awaiting_static_pass.each do |source|
        root_s_expressions = SExpression.from_tokens(Lexer.new(source).each_token)
        root_s_expressions.each do |root_s_expression|
          root_ast_node = AstNode.from_s_expression(root_s_expression)
          self.result = Jobs::Evaluation.new(root_ast_node).tap(&:enqueue!)
        end
      end
      sources_awaiting_static_pass.clear

      work_queue.pump! while result.incomplete?
    end
  end

  attr_accessor :result
  delegate :type, :value, to: :result, prefix: true

  def current_super_binding
    @current_super_binding ||= root_super_binding
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

  def root_super_binding
    @root_super_binding ||= RootSuperBinding.instance.spawn
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

  private
  
  def sources_awaiting_static_pass
    @sources_awaiting_static_pass ||= []
  end

  def type_inferences
    @type_inferences ||= TypeInferencesCollection.new(self)
  end
end
