module Jobs
  class MessageSendTypeInference
    prepend BaseJob

    def initialize(ast_node)
      @ast_node = ast_node
    end
    attr_reader :ast_node
    delegate :message, :argument_s_expressions, to: :ast_node
    attr_accessor :receiver_type_inference, :decorated_receiver_type_inference, :result_type_inference, :argument_type_inferences
    delegate :type, to: :result_type_inference, allow_nil: true

    def complete?
      receiver_type_inference&.complete? && result_type_inference&.complete?  && argument_type_inferences&.all?(&:complete?)
    end

    def type_check
      @type_check ||= MessageSendTypeCheck.new(self)
    end

    def work!
      if !receiver_type_inference
        self.receiver_type_inference = ast_node.receiver_type_inference
        receiver_type_inference.add_downstream(self)
      end
      return unless receiver_type_inference.complete?

      if decorated_receiver_type_inference.nil?
        self.decorated_receiver_type_inference = receiver_type_inference.type.decorate_message_send_receiver_type_inference(self)
        decorated_receiver_type_inference.add_downstream self
      end
      return unless decorated_receiver_type_inference.complete?

      if argument_type_inferences.nil?
        self.argument_type_inferences = receiver_type_inference.type.message_send_argument_type_inferences(self)
        argument_type_inferences.each { |argument_type_inference| argument_type_inference.add_downstream self }
      end
      return unless argument_type_inferences.all?(&:complete?)

      if result_type_inference.nil?
        self.result_type_inference =
          receiver_type_inference
          .type
          .message_send_result_type_inference(self)
        result_type_inference.add_downstream(self)
      end
    end

    def argument_ast_nodes
      @argument_ast_nodes ||= argument_s_expressions.map(&:ast_node)
    end

    def to_s
      "(#{receiver_type_inference.to_s} #{message}#{argument_s_expressions.map { |s_expression| " #{s_expression.to_s}" }.join})"
    end
  end
end
