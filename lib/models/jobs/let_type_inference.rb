module Jobs
  class LetTypeInference
    prepend BaseJob

    def initialize(message_send_type_inference, type_type_inference)
      @message_send_type_inference = message_send_type_inference
      @type_type_inference = type_type_inference
    end
    attr_reader :message_send_type_inference, :type_type_inference
    attr_accessor :value_ast_node, :value_type_inference
    delegate :argument_s_expressions, to: :message_send_type_inference

    def work!
      unless instance_variable_defined?(:@value_type_inference)
        self.value_ast_node = argument_s_expressions.size == 3 ? AstNode.from_s_expression(argument_s_expressions.third) : nil
        self.value_type_inference = value_ast_node.present? ? Workspace.type_inference_for(value_ast_node) : nil
      end
    end

    def complete?
      instance_variable_defined?(:@value_type_inference)
    end

    def type
      Types::Void.instance
    end

    def type_check
      @type_check ||= LetTypeCheck.new(self)
    end

    def to_s
      "(let #{type_type_inference.to_s} #{value_type_inference&.to_s || "---"})"
    end
  end
end
