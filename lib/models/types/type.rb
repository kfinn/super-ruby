module Types
  class Type
    include Singleton

    def to_s
      "Type"
    end

    def delivery_strategy_for_message(message)
      :dynamic
    end

    def message_send_result_typing(message, argument_typings)
      raise "invalid message: (#{self} #{message} #{argument_typings})"
    end

    def build_message_send_bytecode!(typing)
    end
  end
end
