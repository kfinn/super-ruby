module Types
  class Integer
    include Singleton

    def typing_for_message_send(message, argument_types)
      case message
      when '+'
        raise "invalid arguments: #{argument_typings.map(&:to_s).join(", ")}" unless argument_typings.map(&:type) == [self]
        ConcreteProcedure.new()
      else
        raise "invalid message: #{message}"
      end
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
