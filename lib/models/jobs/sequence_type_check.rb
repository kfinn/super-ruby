module Jobs
  class SequenceTypeCheck
    prepend BaseJob

    def initialize(child_type_inferences, additional_type_checks: [])
      child_type_inferences.each do |child_type_inference|
        if child_type_inference.complete?
          child_type_check = child_type_inference.type_check
          child_type_checks << child_type_check
          child_type_check.add_downstream self
        else
          incomplete_child_type_inferences << child_type_inference
          child_type_inference.add_downstream self
        end
      end
      additional_type_checks.each do |type_check|
        child_type_checks << type_check
        type_check.add_downstream  self
      end
    end

    attr_reader :child_type_inferences

    def incomplete_child_type_inferences
      @incomplete_child_type_inferences ||= Set.new
    end

    def child_type_checks
      @child_type_checks ||= Set.new
    end

    def complete?
      incomplete_child_type_inferences.empty? && child_type_checks.all?(&:complete?)
    end

    def valid?
      child_type_checks.all?(&:valid?)
    end

    def work!
      newly_completed_child_type_inferences = []
      incomplete_child_type_inferences.each do |child_type_inference|
        if child_type_inference.complete?
          child_type_checks << child_type_inference.type_check
          child_type_inference.type_check.add_downstream self
          newly_completed_child_type_inferences << child_type_inference
        end
      end
      self.incomplete_child_type_inferences.subtract(newly_completed_child_type_inferences)
    end

    def to_s
      ''
    end
  end
end
