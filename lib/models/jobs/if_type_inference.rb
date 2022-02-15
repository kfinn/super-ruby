module Jobs
  class IfTypeInference
    prepend BaseJob

    def initialize(condition_type_inference, then_branch_type_inference, else_branch_type_inference)
      @condition_type_inference = condition_type_inference
      @then_branch_type_inference = then_branch_type_inference
      @else_branch_type_inference = else_branch_type_inference || ImmediateTypeInference.new(Types::Void.instance)

      @condition_type_inference.add_downstream(self)
      @then_branch_type_inference.add_downstream(self)
      @else_branch_type_inference.add_downstream(self)
    end
    attr_reader :condition_type_inference, :then_branch_type_inference, :else_branch_type_inference
    attr_writer :type

    def upstreams_complete?
      @upstreams_complete ||= [condition_type_inference, then_branch_type_inference, else_branch_type_inference].all?(&:complete?)
    end

    def complete?
      upstreams_complete? && checked?
    end

    def work!
      return unless upstreams_complete?
      check!
    end

    def check!
      return if checked?
      raise "invalid if condition: expected Boolean, got #{condition_type_inference.type}" unless condition_type_inference.type == Types::Boolean.instance
      self.checked = true
    end

    attr_accessor :checked
    alias checked? checked

    def type
      @type ||=
        if then_branch_type_inference.type == else_branch_type_inference.type
          then_branch_type_inference.type
        else
          Types::Intersection.from_types(then_branch_type_inference.type, else_branch_type_inference.type)
        end
    end

    def to_s
      "(if #{condition_type_inference.to_s} #{then_branch_type_inference.to_s} #{else_branch_type_inference.to_s})"
    end
  end
end
