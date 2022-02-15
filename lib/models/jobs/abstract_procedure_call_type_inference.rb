module Jobs
  class AbstractProcedureCallTypeInference
    prepend BaseJob

    def initialize(abstract_procedure, argument_type_inferences)
      @abstract_procedure = abstract_procedure
      @argument_type_inferences = argument_type_inferences
    end
    attr_reader :abstract_procedure, :argument_type_inferences
    attr_accessor :implicit_procedure_specialization
    delegate :complete?, :concrete_procedure, to: :implicit_procedure_specialization

    def type
      concrete_procedure.return_type
    end

    def type_check
      @type_check ||= ConcreteProcedureCallTypeCheck.new(concrete_procedure, argument_type_inferences.map(&:type))
    end

    def implicit_procedure_specialization
      @implicit_procedure_specialization ||=
        Jobs::ImplicitProcedureSpecialization.new(
          abstract_procedure,
          argument_type_inferences
        ).tap do |built|
          built.add_downstream(self)
        end
    end

    def work!; end

    def to_s
      "((AbstractProcedure (#{abstract_procedure.argument_names.map { "?" }.join(" ")}) ?) call#{argument_type_inferences.map { |argument_type_inference| " #{argument_type_inference.to_s}" }.join})"
    end
  end
end
