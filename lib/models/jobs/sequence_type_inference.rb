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
    attr_accessor :worked
    alias worked? worked

    def complete?
      child_type_inferences.all?(&:complete?)
    end

    def type_check
      @type_check = SequenceTypeCheck.new(child_type_inferences.map(&:type_check))
    end

    def work!; end

    def type
      child_type_inferences.last.type
    end
  end
end
