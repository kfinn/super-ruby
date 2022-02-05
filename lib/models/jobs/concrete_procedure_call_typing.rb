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
    attr_accessor :validated
    alias validated? validated
    alias complete? validated?

    def type
      concrete_procedure.return_type
    end

    def upstream_typings_complete?
      argument_typings_by_name.values.all?(&:complete?)
    end

    def work!
      return unless upstream_typings_complete?
      return if validated?

      self.validated = true
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
    end
  end
end
