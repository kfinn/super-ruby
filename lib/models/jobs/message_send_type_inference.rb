module Jobs
  class MessageSendTypeInference
    prepend BaseJob

    def initialize(receiver_type_inference, message, argument_s_expressions)
      @receiver_type_inference = receiver_type_inference
      @message = message
      @argument_s_expressions = argument_s_expressions
    end
    attr_reader :receiver_type_inference, :message, :argument_s_expressions
    attr_accessor :added_downstream, :result_type_inference
    delegate :type, to: :result_type_inference, allow_nil: true

    def complete?
      receiver_type_inference.complete? && result_type_inference&.complete?
    end

    def type_check
      @type_check ||= MessageSendTypeCheck.new(
        receiver_type_inference,
        result_type_inference
      )
    end

    def work!
      if !added_downstream
        self.added_downstream = true
        receiver_type_inference.add_downstream(self)
      end
      return unless receiver_type_inference.complete?
      if self.result_type_inference.nil?
        self.result_type_inference =
          receiver_type_inference
          .type
          .message_send_result_type_inference(
            message,
            argument_s_expressions
          )
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
