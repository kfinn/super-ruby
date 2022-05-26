module Jobs
  class SequenceTypeCheck
    prepend BaseJob

    def initialize(child_type_inferences)
      @child_type_inferences = child_type_inferences
    end

    attr_reader :child_type_inferences
    attr_accessor :added_downstreams, :child_type_checks

    def complete?
      child_type_checks&.all?(&:complete?)
    end

    def valid?
      child_type_checks.all?(&:valid?)
    end

    def errors
      child_type_checks.flat_map(&:errors)
    end

    def work!
      if !added_downstreams
        self.added_downstreams = true
        child_type_inferences.each do |child_type_inference|
          child_type_inference.add_downstream self
        end
      end
      return unless child_type_inferences.all?(&:complete?)

      if !child_type_checks
        self.child_type_checks = child_type_inferences.map(&:type_check)
        child_type_checks.each do |child_type_check|
          child_type_check.add_downstream self
        end
      end
    end
  end
end
