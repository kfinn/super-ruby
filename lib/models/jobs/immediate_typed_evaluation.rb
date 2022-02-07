module Jobs
  class ImmediateTypedEvaluation
    prepend BaseJob

    def initialize(type, value)
      @type = type
      @value = value
    end

    attr_reader :type, :value

    def complete?
      true
    end

    def ==(other)
      other.kind_of? self.class && state == other.state
    end

    def state
      [type, value]
    end

    delegate :hash, to: :state
  end
end
