module Jobs
  class MessageSendTypeCheck
    prepend BaseJob

    def initialize(message_send_type_inference)
      @message_send_type_inference = message_send_type_inference
    end
    attr_reader :message_send_type_inference
    delegate :receiver_type_inference, :argument_type_inferences, :result_type_inference, to: :message_send_type_inference
    attr_accessor :added_downstream, :receiver_type_check, :result_type_check, :argument_type_checks

    def complete?
      receiver_type_check&.complete? && result_type_check&.complete? && argument_type_checks.all?(&:complete?)
    end

    def valid?
      receiver_type_check&.valid? && result_type_check&.valid? && argument_type_checks.all?(&:valid?)
    end

    def work!
      if !added_downstream
        self.added_downstream = true
        message_send_type_inference.add_downstream self
      end
      return unless message_send_type_inference.complete?

      if receiver_type_check.nil?
        self.receiver_type_check = receiver_type_inference.type_check
        receiver_type_check.add_downstream self
      end

      if result_type_check.nil?
        self.result_type_check = result_type_inference.type_check
        result_type_check.add_downstream self
      end

      if argument_type_checks.nil?
        self.argument_type_checks = argument_type_inferences.map(&:type_check)
        argument_type_checks.each { |argument_type_check| argument_type_check.add_downstream self }
      end
    end
  end
end
