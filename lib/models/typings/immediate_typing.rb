module Typings
  class ImmediateTyping
    prepend WorkQueue::Job

    def initialize(type)
      @type = type
    end
    attr_reader :type

    def complete?
      true
    end
  end
end
