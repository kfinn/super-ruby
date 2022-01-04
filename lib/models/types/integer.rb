module Types
  class Integer
    include Singleton

    def message_send_result_type(message, argument_types)
      case message
      when '+'
        raise "invalid arguments: #{argument_types.map(&:to_s).join(", ")}" unless argument_types == [self]
        self
      else
        raise "invalid message: #{message}"
      end
    end
  end
end
