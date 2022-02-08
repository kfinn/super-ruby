module Jobs
  class ImmediateTyping
    prepend BaseJob

    def initialize(type)
      @type = type
    end
    attr_reader :type

    def complete?
      true
    end

    def ==(other)
      other.kind_of?(ImmediateTyping) && type == other.type
    end

    delegate :hash, to: :state

    delegate :to_s, to: :type
  end
end
