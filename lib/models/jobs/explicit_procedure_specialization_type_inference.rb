module Jobs
  class ExplicitProcedureSpecializationTypeInference
    prepend BaseJob

    def initialize(abstract_procedure, concrete_procedure_evaluation)
      @abstract_procedure = abstract_procedure
      @concrete_procedure_evaluation = concrete_procedure_evaluation
    end
    attr_reader :abstract_procedure, :concrete_procedure_evaluation
    attr_accessor :added_downstreams, :declared
    alias complete? declared

    def concrete_procedure
      concrete_procedure_evaluation.value
    end
    alias type concrete_procedure

    delegate :argument_types, to: :concrete_procedure
    delegate :concrete_procedure_instance, to: :type_check

    def type_check
      @type_check ||= ExplicitProcedureSpecializationTypeCheck.new(
        abstract_procedure,
        concrete_procedure_evaluation
      )
    end

    def work!
      if !added_downstreams
        self.added_downstreams = true
        concrete_procedure_evaluation.add_downstream self
      end
      return unless concrete_procedure_evaluation.complete?
      self.declared = true
      abstract_procedure.declare_specialization(argument_types)
    end

    def to_s
      "(#{abstract_procedure.to_s} specialize #{concrete_procedure_evaluation.to_s})"
    end
  end
end
