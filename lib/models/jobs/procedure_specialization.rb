module Jobs
  class ProcedureSpecialization
    prepend BaseJob

    def initialize(abstract_procedure, argument_typings_by_name)
      @abstract_procedure = abstract_procedure
      @argument_typings_by_name = argument_typings_by_name
    end
    attr_reader :abstract_procedure, :argument_typings_by_name
    delegate :ast_node, :workspace, :super_binding, to: :abstract_procedure
    attr_accessor :concrete_procedure, :return_typing
    alias type concrete_procedure
    alias value concrete_procedure

    def specialized?
      concrete_procedure.present?
    end

    def complete?
      specialized?
    end

    def work!
      return unless argument_typings_complete?
      return if specialized?

      cached_concrete_procedure = abstract_procedure.cached_concrete_procedure_for_argument_types(argument_types_by_name) ||
      self.concrete_procedure =
        if cached_concrete_procedure.present?
          cached_concrete_procedure
        else
          Types::ConcreteProcedure.new(self).tap do |constructed_concrete_procedure|
            abstract_procedure.define_concrete_procedure(constructed_concrete_procedure)
          end
        end
    end

    def argument_typings
      argument_typings_by_name.values
    end

    def argument_types_by_name
      @argument_types_by_name ||= argument_typings_by_name.transform_values(&:value)
    end

    def argument_typings_complete?
      argument_typings.all?(&:complete?)
    end

    def return_typing_complete?
      return_typing&.complete?
    end
  end
end
