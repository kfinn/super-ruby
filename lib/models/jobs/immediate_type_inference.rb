module Jobs
  class ImmediateTypeInference
    prepend BaseJob

    def initialize(type)
      @type = type
    end
    attr_reader :type

    def complete?
      true
    end

    def type_check
      ImmediateTypeCheck.success
    end

    def ==(other)
      other.kind_of?(ImmediateTypeInference) && type == other.type
    end

    delegate :hash, to: :state

    delegate :to_s, to: :type
  end
end
