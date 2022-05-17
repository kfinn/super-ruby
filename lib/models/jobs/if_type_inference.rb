module Jobs
  class IfTypeInference
    prepend BaseJob

    def initialize(condition_type_inference, then_branch_type_inference, else_branch_type_inference)
      @condition_type_inference = condition_type_inference
      @then_branch_type_inference = then_branch_type_inference
      @else_branch_type_inference = else_branch_type_inference || ImmediateTypeInference.new(Types::Void.instance)
    end
    attr_reader :condition_type_inference, :then_branch_type_inference, :else_branch_type_inference
    attr_accessor :added_downstreams

    def complete?
      [condition_type_inference, then_branch_type_inference, else_branch_type_inference].all?(&:complete?)
    end

    def work!
      if !added_downstreams
        self.added_downstreams = true
        condition_type_inference.add_downstream(self)
        then_branch_type_inference.add_downstream(self)
        else_branch_type_inference.add_downstream(self)
      end
    end

    def type_check
      @type_check ||= IfTypeCheck.new(
        condition_type_inference,
        then_branch_type_inference, 
        else_branch_type_inference,
      )
    end

    def type
      @type ||= Types::Intersection.from_types(then_branch_type_inference.type, else_branch_type_inference.type)
    end

    def to_s
      "(if #{condition_type_inference.to_s} #{then_branch_type_inference.to_s} #{else_branch_type_inference.to_s})"
    end
  end
end
