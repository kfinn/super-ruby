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
    attr_accessor :result_type_inference, :argument_type_inferences
    delegate :type, to: :result_type_inference, allow_nil: true
    delegate :type_check, to: :result_type_inference

    def upstream_type_inferences_complete?
      @upstream_type_inferences_complete ||= receiver_type_inference.complete? && !argument_type_inferences.nil? && argument_type_inferences.all?(&:complete?)
    end

    def result_type_inference_complete?
      result_type_inference&.complete?
    end

    def complete?
      upstream_type_inferences_complete? && result_type_inference_complete?
    end

    def work!
      if receiver_type_inference.complete? && argument_type_inferences.nil?
        case receiver_type_inference.type.delivery_strategy_for_message(message)
        when :static
          self.argument_type_inferences = argument_ast_nodes.map do |argument_ast_node|
            Evaluation.new(argument_ast_node)
          end
        when :dynamic
          self.argument_type_inferences = argument_ast_nodes.map do |argument_ast_node|
            Workspace.current_workspace.type_inference_for argument_ast_node
          end
        end
        argument_type_inferences.each do |argument_type_inference|
          argument_type_inference.add_downstream self
        end
      end

      if !argument_type_inferences.nil? && argument_type_inferences.all?(&:complete?)
        self.result_type_inference =
          receiver_type_inference
          .type
          .message_send_result_type_inference(
            message,
            argument_type_inferences
          )
        result_type_inference.add_downstream(self)
      end
    end

    def to_s
      "(#{receiver_type_inference.to_s} #{message}#{argument_ast_nodes.map { |ast_node| " #{ast_node.s_expression.to_s}" }.join})"
    end
  end
end
