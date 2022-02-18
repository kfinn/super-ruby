module Jobs
  class MessageSendTypeInference
    prepend BaseJob

    def initialize(receiver_type_inference, message, argument_ast_nodes)
      @receiver_type_inference = receiver_type_inference
      @message = message
      @argument_ast_nodes = argument_ast_nodes

      @receiver_type_inference.add_downstream(self)
    end
    attr_reader :receiver_type_inference, :message, :argument_ast_nodes
    attr_accessor :result_type_inference
    delegate :type, to: :result_type_inference, allow_nil: true

    def complete?
      receiver_type_inference.complete? && result_type_inference&.complete?
    end

    def type_check
      @type_check ||= Jobs::SequenceTypeCheck.new([
        receiver_type_inference.type_check,
        result_type_inference.type_check
      ])
    end

    def work!
      return unless receiver_type_inference.complete?
      if self.result_type_inference.nil?
        self.result_type_inference =
          receiver_type_inference
          .type
          .message_send_result_type_inference(
            message,
            argument_ast_nodes
          )
        result_type_inference.add_downstream(self)
      end
    end

    def to_s
      "(#{receiver_type_inference.to_s} #{message}#{argument_ast_nodes.map { |ast_node| " #{ast_node.s_expression.to_s}" }.join})"
    end
  end
end
