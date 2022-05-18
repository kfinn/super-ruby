module Jobs
  class MessageSendTypeInference
    prepend BaseJob

    def initialize(receiver_type_inference, message, argument_s_expressions)
      @receiver_type_inference = receiver_type_inference
      @message = message
      @argument_s_expressions = argument_s_expressions

      @receiver_type_inference.add_downstream(self)
    end
    attr_reader :receiver_type_inference, :message, :argument_s_expressions
    attr_accessor :decorated_receiver_type_inference, :result_type_inference
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
      return unless receiver_type_inference.complete?

      if decorated_receiver_type_inference.nil?
        self.decorated_receiver_type_inference = receiver_type_inference.type.decorate_message_send_receiver_type_inference(self)
        decorated_receiver_type_inference.add_downstream self
      end
      return unless decorated_receiver_type_inference.complete?

      if result_type_inference.nil?
        self.result_type_inference =
          receiver_type_inference
          .type
          .message_send_result_type_inference(
            self
          )
        result_type_inference.add_downstream(self)
      end
    end

    def to_s
      "(#{receiver_type_inference.to_s} #{message}#{argument_s_expressions.map { |s_expression| " #{s_expression.to_s}" }.join})"
    end
  end
end
