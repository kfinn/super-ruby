module SuperRuby
  class BytecodeSymbolId
    def self.next(description)
      @next_id ||= 1
      id = @next_id
      @next_id += 1
      "#{description}__#{id}"
    end
  end
end
