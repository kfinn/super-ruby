module Jobs
  class ExplicitProcedureSpecializationTypeCheck
    prepend BaseJob

    def initialize(abstract_procedure, concrete_procedure_evaluation)
      @abstract_procedure = abstract_procedure
      @concrete_procedure_evaluation = concrete_procedure_evaluation
    end
    attr_reader :abstract_procedure, :concrete_procedure_evaluation
    attr_accessor :added_downstreams, :implicit_procedure_specialization, :implicit_procedure_specialization_type_check
    delegate :argument_types, to: :concrete_procedure
    delegate :argument_names, :ast_node, :workspace, :super_binding, to: :abstract_procedure

    def concrete_procedure_instance
      raise "attempting to access a concrete procedure before its type check is complete" unless complete?
      implicit_procedure_specialization.concrete_procedure_instance
    end

    attr_accessor :validated, :valid, :errors
    alias complete? validated
    alias valid? valid

    def concrete_procedure
      concrete_procedure_evaluation.value
    end

    def work!
      if !added_downstreams
        self.added_downstreams = true
        concrete_procedure_evaluation.add_downstream(self)
      end
      return unless concrete_procedure_evaluation.complete?

      if implicit_procedure_specialization.nil?
        self.implicit_procedure_specialization = abstract_procedure.implicit_procedure_specialization_for_argument_types(argument_types)
        implicit_procedure_specialization.add_downstream(self)  
      end
      return unless implicit_procedure_specialization.complete?

      if implicit_procedure_specialization_type_check.nil?
        self.implicit_procedure_specialization_type_check = implicit_procedure_specialization.type_check
        implicit_procedure_specialization_type_check.add_downstream(self)
      end
      return unless implicit_procedure_specialization_type_check.complete?

      self.validated = true
      self.valid = implicit_procedure_specialization_type_check.valid? && implicit_procedure_specialization.type == concrete_procedure
      self.errors = implicit_procedure_specialization_type_check.errors + (implicit_procedure_specialization.type == concrete_procedure ? [] : ["Expected: #{implicit_procedure_specialization.type.to_s}, actual: #{concrete_procedure.to_s}"])
    end
  end
end
