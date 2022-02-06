module Types
  class Boolean
    include Singleton

    def to_s
      "Boolean"
    end

    def delivery_strategy_for_message(message)
      :dynamic
    end
  end
end
