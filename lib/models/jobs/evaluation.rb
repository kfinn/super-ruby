module Jobs
  class Evaluation
    prepend BaseJob

    def initialize(ast_node)
      @ast_node = ast_node
    end
    attr_reader :ast_node
    attr_accessor :type_inference, :type_check
    delegate :ast_node, :type, to: :ast_node
    attr_accessor :evaluated
    alias complete? evaluated

    def work!
      if type_inference.nil?
        self.type_inference = Workspace.current_workspace.type_inference_for ast_node
        type_inference.add_downstream self
      end
      return unless type_inference.complete?

      if type_check.nil?
        self.type_check = ast_node.type_check
        type_check.add_downstream self
      end
      return unless type_check.complete?

      self.evaluated = true
      puts "evaluating #{ast_node.s_expression} within #{super_binding.to_s}" if ENV['DEBUG']
      self.value = ast_node.evaluate(ast_node)
    end

    def to_s
      ast_node.s_expression.to_s
    end
  end
end
