module Jobs
  class TypeConstraint
    prepend BaseJob

    def initialize(type_inference, required_type)
      @type_inference = type_inference
      @required_type = required_type
      type_inference.add_downstream self
    end
    attr_reader :type_inference, :required_type
    attr_accessor :validated, :valid
    alias valid? valid
    alias complete? validated

    def work!
      return unless type_inference.complete?
      self.validated = true
      self.valid = type_inference.type == required_type
    end
  end
end
