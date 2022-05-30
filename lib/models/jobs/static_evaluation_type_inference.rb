module Jobs
  class StaticEvaluationTypeInference
    prepend BaseJob

    def initialize(ast_node)
      @ast_node = ast_node
    end
    attr_reader :ast_node
    attr_accessor :ast_node_type_inference, :type_check

    delegate :complete?, to: :ast_node_type_inference, allow_nil: true
    delegate :type, to: :ast_node_type_inference

    def work!
      if type_check.nil?
        self.type_check = StaticEvaluationTypeCheck.new(self)
      end

      if ast_node_type_inference.nil?
        self.ast_node_type_inference =
          Workspace.with_current_super_binding(
            Workspace.current_super_binding.spawn(
              inherit_dynamic_locals: true,
              deferred_static_type_check: type_check
            )
          ) do
            Workspace.type_inference_for ast_node
          end
        ast_node_type_inference.add_downstream self
      end
    end

    delegate :add_deferred_type_check, to: :type_check

    def evaluation
      @evaluation ||= Evaluation.new(ast_node, type_inference: ast_node_type_inference, type_check: type_check)
    end

    delegate :value, :build_static_value_llvm!, to: :evaluation
  end
end
