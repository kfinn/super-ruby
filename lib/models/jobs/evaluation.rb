module Jobs
  class Evaluation
    prepend BaseJob

    def initialize(ast_node, type_inference: nil, type_check: nil)
      @ast_node = ast_node
      self.type_inference = type_inference
      self.type_check = type_check

      type_inference&.add_downstream(self)
      type_check&.add_downstream(self)
    end
    attr_reader :ast_node
    attr_accessor :type_inference, :type_check
    delegate :type, to: :type_inference
    delegate :complete?, to: :type_check, allow_nil: true

    attr_accessor :value_entered
    alias value_entered? value_entered

    def value
      raise "attempting to access the value of #{ast_node.to_s} (#{(type_inference || 'nil').to_s}) before it is type checked" unless complete?
      raise "infinite loop detected trying to evaluate #{ast_node.to_s}" if value_entered? && !instance_variable_defined?(:@value)
      self.value_entered = true
      in_context do
        @value ||= ast_node.evaluate(type_inference)
      end
    end

    def work!
      if type_inference.nil?
        self.type_inference = Workspace.current_workspace.type_inference_for ast_node
        type_inference.add_downstream self
      end
      return unless type_inference.complete?

      if type_check.nil?
        self.type_check = type_inference.type_check
        type_check.add_downstream self
      end
    end

    def to_s
      ast_node.s_expression.to_s
    end
  end
end
