module Jobs
  class Evaluation
    prepend BaseJob

    def initialize(ast_node)
      @ast_node = ast_node
      @type_inference = Workspace.current_workspace.type_inference_for(@ast_node)
      @type_inference.add_downstream(self)
      @super_binding = Workspace.current_workspace.current_super_binding
    end
    attr_reader :ast_node, :type_inference, :super_binding
    attr_accessor :evaluated, :value
    alias evaluated? evaluated
    delegate :type, to: :type_inference

    def work!
      return unless type_inference.complete?
      self.evaluated = true
      puts "evaluating #{ast_node.s_expression} within #{super_binding.to_s}" if ENV['DEBUG']
      Workspace.current_workspace.with_current_super_binding(super_binding) do
        self.value = ast_node.evaluate(type_inference)
      end
    end

    def complete?
      evaluated?
    end

    def to_s
      ast_node.s_expression.to_s
    end
  end
end
