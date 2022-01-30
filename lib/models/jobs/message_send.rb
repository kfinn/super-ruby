module Jobs
  class MessageSend
    prepend BaseJob

    def initialize(receiver_typing, message, argument_typings)
      @receiver_typing = receiver_typing
      @message = message
      @argument_typings = argument_typings

      @receiver_typing.add_downstream(self)
      @argument_typings.each do |argument_typing|
        argument_typing.add_downstream(self)
      end
    end
    attr_reader :receiver_typing, :message, :argument_typings
    attr_accessor :result_typing

    def upstream_typings_complete?
      @upstream_typings_complete ||= receiver_typing.complete? && argument_typings.all?(&:complete?)
    end

    def result_typing_complete?
      result_typing&.complete?
    end

    def complete?
      upstream_typings_complete? && result_typing_complete?
    end

    def work!
      if receiver_typing.complete? && result_typing.blank?
        self.result_typing =
          receiver_typing
          .type
          .message_send_result_typing(
            message,
            argument_typings
          )
        result_typing.add_downstream(self)
      end
    end

    def type
      @type ||= result_typing.type
    end

    def to_s
      "message send: #{message}"
    end
  end
end
