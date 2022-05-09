module Jobs
  class StaticEvaluationTypeInference
    prepend BaseJob

    def initialize(ast_node)
      @ast_node = ast_node
    end
    attr_reader :ast_node
    attr_accessor :ast_node_type_inference

    delegate :complete?, to: :ast_node_type_inference, allow_nil: true
    delegate :type, :type_check, to: :ast_node_type_inference

    def work!
      if ast_node_type_inference.nil?
        self.ast_node_type_inference = Workspace.current_workspace.type_inference_for ast_node
        ast_node_type_inference.add_downstream self
      end
      return unless ast_node_type_inference.complete?
    end

    def evaluation
      @evaluation ||= Evaluation.new(ast_node, type_inference: ast_node_type_inference, type_check: type_check)
    end

    delegate :value, to: :evaluation
  end
end
