module Jobs
  class SequenceTypeInference
    prepend BaseJob

    def initialize(child_type_inferences)
      @child_type_inferences = child_type_inferences

      @child_type_inferences.each do |child_type_inference|
        child_type_inference.add_downstream(self)
      end
    end
    attr_reader :child_type_inferences

    def complete?
      child_type_inferences.all?(&:complete?)
    end

    def type_check
      @type_check = SequenceTypeCheck.new(child_type_inferences)
    end

    def work!; end

    def type
      child_type_inferences.last.type
    end

    def to_s
      "(sequence (#{child_type_inferences.map(&:to_s).join(" ")}))"
    end
  end
end
