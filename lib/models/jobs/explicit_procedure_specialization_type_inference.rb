module Jobs
  class ExplicitProcedureSpecializationTypeInference
    prepend BaseJob

    def initialize(abstract_procedure, concrete_procedure_type_inference)
      @abstract_procedure = abstract_procedure
      @concrete_procedure_type_inference = concrete_procedure_type_inference
      concrete_procedure_type_inference.add_downstream(self)
    end
    attr_reader :abstract_procedure, :concrete_procedure_type_inference
    attr_accessor :declared
    alias declared? declared
    alias complete? declared

    def concrete_procedure
      concrete_procedure_type_inference.value
    end
    alias type concrete_procedure

    delegate :argument_types, to: :concrete_procedure

    def type_check
      @type_check ||= ExplicitProcedureSpecializationTypeCheck.new(
        abstract_procedure,
        concrete_procedure
      )
    end

    def work!
      return unless concrete_procedure_type_inference.complete?
      unless declared?
        self.declared = true
        abstract_procedure.declare_specialization(argument_types)
      end
    end

    def to_s
      "(#{abstract_procedure.to_s} specialize #{concrete_procedure_type_inference.to_s})"
    end
  end
end
