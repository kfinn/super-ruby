module Jobs
  class SetterCallTypeCheck
    prepend BaseJob

    def initialize(setter_call_type_inference)
      @setter_call_type_inference = setter_call_type_inference
    end
    attr_reader :setter_call_type_inference
    delegate :field_type_inference, :value_type_inference, to: :setter_call_type_inference
    attr_accessor :field_type_check, :value_type_check, :validated, :valid, :errors
    alias complete? validated
    alias valid? valid

    def work!
      if field_type_check.nil?
        self.field_type_check = field_type_inference.type_check
        field_type_check.add_downstream self
      end

      if value_type_check.nil?
        self.value_type_check = value_type_inference.type_check
        value_type_check.add_downstream self
      end
      return unless field_type_check.complete? && value_type_check.complete?

      self.validated = true
      self.valid = field_type_check.valid? && value_type_check.valid? && field_type_inference.type == value_type_inference.type
      self.errors = field_type_check.errors + value_type_check.errors + (field_type_inference.type == value_type_inference.type ? [] : ["Expected: #{field_type_inference.type.to_s}, actual: #{value_type_inference.type.to_s}"])
    end
  end
end
