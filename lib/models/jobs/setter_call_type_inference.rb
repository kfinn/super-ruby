module Jobs
  class SetterCallTypeInference
    prepend BaseJob
    
    def initialize(field_type_inference, value_type_inference)
      @field_type_inference = field_type_inference
      @value_type_inference = value_type_inference
    end
    attr_reader :field_type_inference, :value_type_inference
    attr_accessor :added_downstream
    
    def complete?
      field_type_inference.complete?
    end

    def work!
      if !added_downstream
        self.added_downstream = true
        value_type_inference.add_downstream self
      end
    end

    def type_check
      @type_check ||= SetterCallTypeCheck.new(self)
    end
  end
end
