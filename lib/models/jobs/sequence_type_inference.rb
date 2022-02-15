module Jobs
  class SequenceTypeInference
    prepend BaseJob

    def initialize(child_typings)
      @child_typings = child_typings

      @child_typings.each do |child_typing|
        child_typing.add_downstream(self)
      end
    end
    attr_reader :child_typings
    attr_accessor :worked
    alias worked? worked

    def complete?
      child_typings.all?(&:complete?)
    end

    def work!; end

    def type
      child_typings.last.type
    end
  end
end
