module Jobs
  class ProcedureSpecialization
    prepend BaseJob

    def initialize(abstract_procedure, argument_typings)
      @abstract_procedure = abstract_procedure
      @argument_typings = argument_typings
    end
    
    attr_reader :abstract_procedure, :argument_typings
    attr_accessor :result_typing
    delegate :argument_names, :body, to: :abstract_procedure

    def work!
      return if self.argument_typings.any?(&:incomplete?)
      return if self.result_typing.present?

      workspace = Workspace.current_workspace
      workspace.with_current_super_binding(super_binding) do
        self.result_typing = workspace.typing_for(body)
        self.result_typing.add_downstream(self)
      end
    end

    def complete?
      self.argument_typings.all?(&:complete) && self.result_typing&.complete?
    end

    def super_binding
      @super_binding ||=
        argument_names
        .zip(argument_typings)
        .each_with_object(
          Workspace
          .current_super_binding
          .spawn
        ) do |(argument_name, argument_type), super_binding|
          super_binding.set(
            argument_name,
            argument_typing
          )
        end
    end
  end
end
