module Jobs
  class StaticEvaluationTypeCheck
    prepend BaseJob

    def initialize(static_evaluation_type_inference)
      @static_evaluation_type_inference = static_evaluation_type_inference
    end
    attr_reader :static_evaluation_type_inference
    attr_accessor :added_type_inference_downstream, :original_type_check, :validated, :valid, :errors
    alias valid? valid
    alias complete? validated

    def add_deferred_type_check(deferred_type_check)
      return if deferred_type_check == self
      deferred_type_checks << deferred_type_check
      deferred_type_check.add_downstream self
    end

    def deferred_type_checks
      @deferred_type_checks ||= Set.new
    end

    def work!
      unless added_type_inference_downstream
        self.added_type_inference_downstream = true
        static_evaluation_type_inference.add_downstream self
      end
      return unless static_evaluation_type_inference.complete?

      if original_type_check.nil?
        self.original_type_check =static_evaluation_type_inference.ast_node_type_inference.type_check
        original_type_check.add_downstream self
      end
      return unless original_type_check.complete?

      return unless deferred_type_checks.all?(&:complete?)

      self.validated = true
      self.valid = original_type_check.valid? && deferred_type_checks.all?(&:valid?)
      self.errors = original_type_check.errors + deferred_type_checks.flat_map(&:errors)
    end
  end
end
