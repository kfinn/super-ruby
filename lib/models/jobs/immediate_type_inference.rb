module Jobs
  class ImmediateTypeInference
    prepend BaseJob
    include DerivesEquality
    
    def initialize(type)
      @type = type
    end
    attr_reader :type
    alias state type

    def complete?
      true
    end

    def type_check
      ImmediateTypeCheck.success
    end

    delegate :to_s, to: :type
  end
end
