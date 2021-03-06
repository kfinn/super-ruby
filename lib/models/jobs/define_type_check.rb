module Jobs
  class DefineTypeCheck
    prepend BaseJob

    def initialize(value_type_inference)
      @value_type_inference = value_type_inference
    end
    attr_reader :value_type_inference
    attr_accessor :added_downstreams, :value_type_check

    delegate :complete?, :valid?, :errors, to: :value_type_check, allow_nil: true

    def work!
      if !added_downstreams
        self.added_downstreams = true
        value_type_inference.add_downstream self
      end
      return unless value_type_inference.complete?

      if value_type_check.nil?
        self.value_type_check = value_type_inference.type_check
        value_type_check.add_downstream self
      end
    end
  end
end
