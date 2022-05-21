module Jobs
  class IfTypeCheck
    prepend BaseJob

    def initialize(condition_type_inference, then_branch_type_inference, else_branch_type_inference)
      @condition_type_inference = condition_type_inference
      @then_branch_type_inference = then_branch_type_inference
      @else_branch_type_inference = else_branch_type_inference

      type_inferences.each do |type_inference|
        type_inference.add_downstream self
      end
    end
    attr_reader :condition_type_inference, :then_branch_type_inference, :else_branch_type_inference
    attr_accessor :type_checks
    attr_accessor :validated, :valid
    alias valid? valid
    alias complete? validated

    def type_inferences
      @type_inferences ||= [condition_type_inference, then_branch_type_inference, else_branch_type_inference]
    end

    def work!
      return unless type_inferences.all?(&:complete?)
      if type_checks.nil?
        self.type_checks = type_inferences.map(&:type_check)
        type_checks.each do |type_check|
          type_check.add_downstream self
        end
      end
      return unless type_checks.all?(&:complete?)

      self.validated = true
      self.valid = type_checks.all?(&:valid?) && condition_type_inference.type == Types::Boolean.instance
    end
  end
end
