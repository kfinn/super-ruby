module Jobs
  class LetTypeInference
    prepend BaseJob

    def initialize(ast_node)
      @ast_node = ast_node

      @type_static_evaluation_type_inference = StaticEvaluationTypeInference.new(type_ast_node)
      @type_type_inference = TypeInferenceGivenByEvaluation.new(type_static_evaluation_type_inference)
      @value_type_inference = Workspace.type_inference_for(value_ast_node) if value_ast_node.present?
    end
    attr_reader :ast_node, :type_static_evaluation_type_inference, :type_type_inference, :value_type_inference
    delegate :type_ast_node, :value_ast_node, to: :ast_node

    def type
      Types::Void.instance
    end

    def complete?
      true
    end

    def type_check
      @type_check ||= LetTypeCheck.new(self)
    end

    def to_s
      "(let #{type_type_inference.to_s} #{value_type_inference&.to_s || "---"})"
    end
  end
end
