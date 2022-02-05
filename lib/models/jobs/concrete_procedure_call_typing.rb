module Jobs
  class ConcreteProcedureCallTyping
    prepend BaseJob

    def initialize(
      concrete_procedure,
      argument_typings_by_name
    )
      @concrete_procedure = concrete_procedure
      @argument_typings_by_name = argument_typings_by_name
      argument_typings_by_name.values.each do |argument_typing|
        argument_typing.add_downstream(self)
      end
    end
    attr_reader :concrete_procedure, :argument_typings_by_name
    attr_accessor :return_typing
    delegate :type, :complete?, to: :return_typing, allow_nil: true

    def upstream_typings_complete?
      argument_typings_by_name.values.all?(&:complete?)
    end

    def work!
      return unless upstream_typings_complete?
      return if return_typing.present?

      mismatched_argument_names = []
      argument_typings_by_name.each do |argument_name, argument_typing|
        if argument_typing.type != concrete_procedure.argument_types_by_name[argument_name]
          mismatched_argument_names << argument_name
        end
      end
      if mismatched_argument_names.any?
        expected_types =
          concrete_procedure.argument_types_by_name.slice(*mismatched_argument_names)
        actual_types =
          argument_typings_by_name
          .slice(*mismatched_argument_names)
          .transform_values(&:type)
        raise "invalid arguments to concrete procedure\n\texpected #{expected_types})\n\tgot #{actual_types}"
      end

      Workspace.current_workspace.with_current_super_binding(concrete_procedure.body_super_binding) do
        self.return_typing = Workspace.current_workspace.typing_for(concrete_procedure.body)
        return_typing.add_downstream(self)
      end
    end
  end
end
