module Jobs
  class StaticEvaluationTypeCheck
    prepend BaseJob

    def initialize(static_evaluation_type_inference)
      @static_evaluation_type_inference = static_evaluation_type_inference
    end
    attr_reader :static_evaluation_type_inference
    attr_accessor :ast_node_type_check

    def work!
      if ast_node_type_check.nil?
        self.ast_node_type_check = static_evaluation_type_inference.type_check
        ast_node_type_check.add_downstream self
    end
    return unless ast_node_type_check.complete?

    
  end
end
