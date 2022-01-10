module Jobs
  class IfTyping
    prepend BaseJob

    def self.handle_ast_node(ast_node)
      return unless (
        ast_node.list? &&
        ast_node.first.atom? &&
        ast_node.first.text == 'if' &&
        ast_node.size.in?(3..4)
      )

      workspace = Workspace.current_workspace
      condition_typing = workspace.typing_for(ast_node.second)
      then_branch_typing =
        workspace
        .with_current_super_binding(
          workspace
          .current_super_binding
          .spawn(inherit_dynamic_locals: true)
        ) do
          workspace.typing_for(ast_node.third)
        end
      else_branch_typing = 
        if ast_node.size > 3
          workspace
          .with_current_super_binding(
            workspace
            .current_super_binding
            .spawn(inherit_dynamic_locals: true)
          ) do
            workspace.typing_for(ast_node.fourth)
          end
        else
          Job::ImmediateTyping.new(Types::Void.instance)
        end

      new(
        condition_typing,
        then_branch_typing,
        else_branch_typing
      ).tap do |if_typing|
        condition_typing.add_downstream(if_typing)
        then_branch_typing.add_downstream(if_typing)
        else_branch_typing.add_downstream(if_typing)
      end
    end

    def initialize(condition_typing, then_branch_typing, else_branch_typing)
      @condition_typing = condition_typing
      @then_branch_typing = then_branch_typing
      @else_branch_typing = else_branch_typing || ImmediateTyping.new(Types::Void.instance)
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
