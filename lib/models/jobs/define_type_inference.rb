module Jobs
  class DefineTypeInference
    prepend BaseJob

    def initialize(value_type_inference)
      @value_type_inference = value_type_inference
    end
    attr_reader :value_type_inference

    def complete?
      true
    end

    def type
      Types::Void.instance
    end

    def type_check
      @type_check ||= DefineTypeCheck.new(value_type_inference)
    end

    def to_s
      ''
    end
  end
end
