module Typings
  class Integer
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
      case message
      when '+'
        raise "invalid arguments: #{argument_typings.map(&:to_s).join(", ")}" unless argument_typings.map(&:type) == [self]
        self
      else
        raise "invalid message: #{message}"
      end
    end
  end
end
