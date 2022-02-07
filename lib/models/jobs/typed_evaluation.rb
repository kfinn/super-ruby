module Jobs
  class TypedEvaluation
    prepend BaseJob

    def initialize(ast_node)
      @ast_node = ast_node
      @typing = Workspace.current_workspace.typing_for(@ast_node)
      @typing.add_downstream(self)
      @super_binding = Workspace.current_workspace.current_super_binding
    end
    attr_reader :ast_node, :typing, :super_binding
    attr_accessor :evaluated, :value
    alias evaluated? evaluated
    delegate :type, to: :typing

    def work!
      return unless typing.complete?
      self.evaluated = true
      puts "evaluating #{ast_node.s_expression} within #{super_binding.to_s}" if ENV['DEBUG']
      Workspace.current_workspace.with_current_super_binding(super_binding) do
        self.value = ast_node.evaluate(typing)
      end
    end

    def complete?
      typing.complete? && evaluated?
    end
  end
end
