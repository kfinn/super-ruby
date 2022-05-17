module Jobs
  class SequenceTypeInference
    prepend BaseJob

    def initialize(child_type_inferences)
      @child_type_inferences = child_type_inferences
    end
    attr_reader :child_type_inferences
    attr_accessor :added_downstreams

    def complete?
      child_type_inferences.all?(&:complete?)
    end

    def type_check
      @type_check = SequenceTypeCheck.new(child_type_inferences)
    end

    def work!
      if !added_downstreams
        self.added_downstreams = true
        child_type_inferences.each do |child_type_inference|
          child_type_inference.add_downstream self
        end
      end
    end

    def type
      child_type_inferences.last.type
    end

    def to_s
      "(sequence (#{child_type_inferences.map(&:to_s).join(" ")}))"
    end
  end
end
