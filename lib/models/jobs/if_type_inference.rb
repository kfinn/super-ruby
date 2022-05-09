module Jobs
  class IfTypeInference
    prepend BaseJob

    def initialize(condition_type_inference, then_branch_type_inference, else_branch_type_inference)
      @condition_type_inference = condition_type_inference
      @then_branch_type_inference = then_branch_type_inference
      @else_branch_type_inference = else_branch_type_inference || ImmediateTypeInference.new(Types::Void.instance)

      @then_branch_type_inference.add_downstream(self)
      @else_branch_type_inference.add_downstream(self)
    end
    attr_reader :condition_type_inference, :then_branch_type_inference, :else_branch_type_inference

    def complete?
      [condition_type_inference, then_branch_type_inference, else_branch_type_inference].all?(&:complete?)
    end

    def work!; end

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
