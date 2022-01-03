module Typings
  class Void
    include Singleton
    def dependencies
      @dependencies ||= []
    end

    def complete?
      true
    end

    def type
      self
    end

    def message_send_result_type(message, argument_typings)
      raise "invalid message: #{message}"
    end
  end
end
