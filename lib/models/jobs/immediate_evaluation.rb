module Jobs
  class ImmediateEvaluation
    prepend BaseJob
    include DerivesEquality

    def initialize(type, value)
      @type = type
      @value = value
    end

    attr_reader :type, :value

    def complete?
      true
    end

    def type_check
      ImmediateTypeCheck.success
    end

    def state
      [type, value]
    end

    def to_s
      "(#{type.to_s} #{value.to_s})"
    end
  end
end
