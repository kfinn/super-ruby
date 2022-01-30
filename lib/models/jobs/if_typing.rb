module Jobs
  class IfTyping
    prepend BaseJob

    def initialize(condition_typing, then_branch_typing, else_branch_typing)
      @condition_typing = condition_typing
      @then_branch_typing = then_branch_typing
      @else_branch_typing = else_branch_typing || ImmediateTyping.new(Types::Void.instance)

      @condition_typing.add_downstream(self)
      @then_branch_typing.add_downstream(self)
      @else_branch_typing.add_downstream(self)
    end
    attr_reader :condition_typing, :then_branch_typing, :else_branch_typing
    attr_writer :type

    def upstreams_complete?
      @upstreams_complete ||= [condition_typing, then_branch_typing, else_branch_typing].all?(&:complete?)
    end

    def complete?
      upstreams_complete? && checked?
    end

    def work!
      return unless upstreams_complete?
      check!
    end

    def check!
      return if checked?
      raise "invalid if condition: expected Boolean, got #{condition_typing.type}" unless condition_typing.type == Types::Boolean.instance
      self.checked = true
    end

    attr_accessor :checked
    alias checked? checked

    def type
      @type ||=
        if then_branch_typing.type == else_branch_typing.type
          then_branch_typing.type
        else
          Types::Intersection.new([then_branch_typing.type, else_branch_typing.type])
        end
    end
  end
end
