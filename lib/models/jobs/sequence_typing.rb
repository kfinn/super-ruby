module Jobs
  class SequenceTyping
    prepend BaseJob

    def initialize(child_typings)
      @child_typings = child_typings
      @super_binding = Workspace.current_workspace.current_super_binding

      @child_typings.each do |child_typing|
        child_typing.add_downstream(self)
      end
    end
    attr_reader :child_typings, :super_binding
    attr_accessor :worked
    alias worked? worked

    def complete?
      @complete ||= child_typings.all?(&:complete?) && worked?
    end

    def work!
      return unless child_typings.all?(&:complete?)
      self.worked = true
    end

    def type
      child_typings.last.type
    end
  end
end
