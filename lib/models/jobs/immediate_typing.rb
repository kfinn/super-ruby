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
  end
end
