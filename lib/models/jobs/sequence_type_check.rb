module Jobs
  class SequenceTypeCheck
    prepend BaseJob

    def initialize(child_type_checks)
      @child_type_checks = child_type_checks
      child_type_checks.each do |child_type_check|
        child_type_check.add_downstream(self)
      end
    end

    attr_reader :child_type_checks

    def complete?
      child_type_checks.all?(&:complete?)
    end

    def valid?
      child_type_checks.all?(&:valid?)
    end

    def work!; end
  end
end
