module Jobs
  class ImmediateEvaluation
    prepend BaseJob

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

    def ==(other)
      other.kind_of? self.class && state == other.state
    end

    def state
      [type, value]
    end

    delegate :hash, to: :state

    def to_s
      "(#{type.to_s} #{value.to_s})"
    end
  end
end
