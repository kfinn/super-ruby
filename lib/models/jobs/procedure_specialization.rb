module Jobs
  class ProcedureSpecialization
    prepend BaseJob

    def initialize(abstract_procedure, argument_typings_by_name)
      @abstract_procedure = abstract_procedure
      @argument_typings_by_name = argument_typings_by_name
    end
    attr_reader :abstract_procedure, :argument_typings_by_name
    delegate :ast_node, :workspace, :super_binding, to: :abstract_procedure
    attr_accessor :return_typing, :concrete_procedure

    def complete?
      concrete_procedure.present?
    end

    def work!
      return unless argument_typings_complete?
      return if concrete_procedure.present?

      cached_concrete_procedure = abstract_procedure.cached_concrete_procedure_for_argument_types(argument_types_by_name.values)
      if cached_concrete_procedure.present?
        self.concrete_procedure = cached_concrete_procedure
        self.return_typing = ImmediateTyping.new(self.concrete_procedure.return_type)
        return
      end

      if return_typing_complete?
        self.concrete_procedure = Types::ConcreteProcedure.new(
          argument_types_by_name.values,
          return_typing.type
        )
        abstract_procedure.define_concrete_procedure(self.concrete_procedure)
        return
      end

      if return_typing.blank?
        body_super_binding =
          argument_typings_by_name
          .each_with_object(
            super_binding.spawn
          ) do |(argument_name, argument_typing), super_binding_builder|
            super_binding_builder.set(
              argument_name,
              argument_typing
            )
          end

        self.return_typing = workspace.with_current_super_binding(body_super_binding) do
          workspace.typing_for(abstract_procedure.body)
        end
        self.return_typing.add_downstream(self)
      end
    end

    def argument_typings
      argument_typings_by_name.values
    end

    def argument_types_by_name
      @argument_types_by_name ||= argument_typings_by_name.transform_values(&:type)
    end

    def argument_typings_complete?
      argument_typings.all?(&:complete?)
    end

    def return_typing_complete?
      return_typing&.complete?
    end
  end
end
