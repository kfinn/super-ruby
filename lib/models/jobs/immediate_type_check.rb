module Jobs
  class ImmediateTypeCheck
    prepend BaseJob

    def self.success
      @success ||= new(true)
    end

    def initialize(valid)
      @valid = valid
    end
    attr_reader :valid
    alias valid? valid

    def complete?
      true
    end
  end
end
