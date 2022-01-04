module Types
  class Integer
    include Singleton

    def message_send_result_typing(message, argument_types)
      case message
      when '+'
        raise "invalid arguments: #{argument_types.map(&:to_s).join(", ")}" unless argument_types == [self]
        immediate_integer_typing
      else
        raise "invalid message: #{message}"
      end
    end

    def immediate_integer_typing
      Typings::ImmediateTyping.new(self)
    end
  end
end
