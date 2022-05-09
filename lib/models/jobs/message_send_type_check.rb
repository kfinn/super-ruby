module Jobs
  class MessageSendTypeCheck
    prepend BaseJob

    def initialize(receiver_type_inference, result_type_inference)
      @receiver_type_inference = receiver_type_inference
      @result_type_inference = result_type_inference

      receiver_type_inference.add_downstream self
      result_type_inference.add_downstream self
    end
    attr_reader :receiver_type_inference, :result_type_inference
    attr_accessor :receiver_type_check, :result_type_check

    def complete?
      receiver_type_check&.complete? && result_type_check&.complete?
    end

    def valid?
      receiver_type_check&.valid? && result_type_check&.valid?
    end

    def work!
      if receiver_type_inference.complete? && receiver_type_check.nil?
        self.receiver_type_check = receiver_type_inference.type_check
        receiver_type_check.add_downstream self
      end

      if result_type_inference.complete? && result_type_check.nil?
        self.result_type_check = result_type_inference.type_check
        result_type_check.add_downstream self
      end
    end
  end
end
