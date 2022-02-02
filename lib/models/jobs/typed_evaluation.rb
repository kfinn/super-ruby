module Jobs
  class TypedEvaluation
    prepend BaseJob

    def initialize(ast_node)
      @ast_node = ast_node
      @typing = Workspace.current_workspace.typing_for(@ast_node)
      @typing.add_downstream(self)
    end
    attr_reader :ast_node, :typing, :strategy
    attr_accessor :evaluated, :value
    alias evaluated? evaluated
    delegate :type, to: :typing

    def work!
      return unless typing.complete?
      self.evaluated = true
      self.value = ast_node.evaluate(typing)
    end

    def complete?
      typing.complete? && evaluated?
    end

    def has_value?
      true
    end
  end
end
