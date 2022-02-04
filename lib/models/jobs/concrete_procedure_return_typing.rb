module Jobs
  class ConcreteProcedureReturnTyping
    prepend BaseJob

    def initialize(
      procedure_specialization,
      argument_typings_by_name = nil
    )
      @procedure_specialization = procedure_specialization
      @argument_typings_by_name = argument_typings_by_name || procedure_specialization.argument_typings_by_name
      procedure_specialization.add_downstream(self)
      if argument_typings_by_name.present?
        argument_typings_by_name.values.each do |argument_typing|
          argument_typing.add_downstream(self)
        end
      end
    end
    attr_reader :procedure_specialization, :argument_typings_by_name
    attr_accessor :validated
    alias validated? validated
    delegate :return_typing, to: :procedure_specialization
    delegate :type, to: :return_typing

    def complete?
      validated?
    end

    def work!
      return unless (
        procedure_specialization.complete? &&
        argument_typings_by_name.values.all?(&:complete?)
      )
      mismatched_argument_names = []
      argument_typings_by_name.each do |argument_name, argument_typing|
        if argument_typing.type != procedure_specialization.argument_types_by_name[argument_name]
          mismatched_argument_names << argument_name
        end
      end
      if mismatched_argument_names.any?
        expected_types =
          procedure_specialization.argument_types_by_name.slice(*mismatched_argument_names)
        actual_types =
          argument_typings_by_name
          .slice(*mismatched_argument_names)
          .transform_values(&:type)
        raise "invalid arguments to concrete procedure\n\texpected #{expected_types})\n\tgot #{actual_types}"
      end
      self.validated = true
    end
  end
end
