module Jobs
  class LetTypeCheck
    prepend BaseJob
    def initialize(let_type_inference)
      @let_type_inference = let_type_inference
    end
    attr_reader :let_type_inference
    attr_accessor :added_downstreams, :value_type_check, :type_type_check, :valid, :validated
    delegate :type_type_inference, :value_type_inference, to: :let_type_inference
    alias valid? valid
    alias complete? validated

    def work!
      return unless let_type_inference.complete?

      if !added_downstreams
        type_type_inference.add_downstream self
        value_type_inference&.add_downstream self
      end
      return if type_type_inference.incomplete? || value_type_inference&.incomplete?

      unless instance_variable_defined?(:@value_type_check)
        self.value_type_check = value_type_inference&.type_check
        value_type_check&.add_downstream self
      end

      if type_type_check.nil?
        self.type_type_check = type_type_inference.type_check
        type_type_check.add_downstream self
      end

      if (type_type_check.incomplete? || (value_type_check.present? && value_type_check.incomplete?))
        return
      end

      self.validated = true
      self.valid = (
        type_type_check.valid? &&
        (value_type_check.nil? || value_type_check.valid?) &&
        (value_type_inference.nil? || value_type_inference.type == type_type_inference.type)
      )
    end
  end
end
