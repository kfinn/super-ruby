module Jobs
  class Evaluation
    prepend BaseJob

    def initialize(ast_node, type_inference: nil, type_check: nil)
      @ast_node = ast_node
      self.type_inference = type_inference
      self.type_check = type_check
    end
    attr_reader :ast_node
    attr_accessor :type_inference, :added_type_inference_downstream, :type_check, :added_type_check_downstream
    delegate :type, to: :type_inference
    delegate :complete?, :valid?, :errors, to: :type_check, allow_nil: true

    def value
      raise "attempting to access the value of #{ast_node.to_s} (#{(type_inference || 'nil').to_s}) before it is type checked" unless complete?
      raise "attempting to access the value of #{ast_node.to_s} (#{(type_inference || 'nil').to_s}) but its type check failed: #{errors}" unless valid?
      in_context do
        @value ||= ast_node.evaluate(type_inference)
      end
    end

    def work!
      if type_inference.nil?
        self.type_inference = Workspace.type_inference_for ast_node
      end
      if !added_type_inference_downstream
        self.added_type_inference_downstream = true
        type_inference.add_downstream self
      end
      return unless type_inference.complete?

      if type_check.nil?
        self.type_check = type_inference.type_check
      end
      if !added_type_check_downstream
        self.added_type_check_downstream = true
        type_check.add_downstream self
      end
    end

    def to_s
      ast_node.s_expression.to_s
    end

    def build_static_value_llvm!
      type.build_static_value_llvm!(value)
    end
  end
end
