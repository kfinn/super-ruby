module Jobs
  class ExplicitProcedureSpecializationTypeCheck
    prepend BaseJob

    def initialize(abstract_procedure, concrete_procedure)
      @abstract_procedure = abstract_procedure
      @concrete_procedure = concrete_procedure
      @implicit_procedure_specialization = abstract_procedure.cached_implicit_procedure_specialization_for_argument_types(argument_types)
      @implicit_procedure_specialization.add_downstream(self)
    end
    attr_reader :abstract_procedure, :concrete_procedure, :implicit_procedure_specialization
    delegate :argument_types, to: :concrete_procedure
    delegate :argument_names, :ast_node, :workspace, :super_binding, to: :abstract_procedure
    delegate :concrete_procedure_instance, to: :implicit_procedure_specialization

    attr_accessor :validated
    alias validated? validated
    alias complete? validated

    attr_accessor :valid
    alias valid? valid

    def work!
      return unless implicit_procedure_specialization.complete?
      unless validated?
        self.validated = true
        self.valid = implicit_procedure_specialization.type == concrete_procedure
      end
    end
  end
end
