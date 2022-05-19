module Jobs
  class ConcreteProcedureCallTypeInference
    prepend BaseJob

    def initialize(
      concrete_procedure,
      argument_type_inferences
    )
      @concrete_procedure = concrete_procedure
      @argument_type_inferences = argument_type_inferences
    end
    attr_reader :concrete_procedure, :argument_type_inferences

    def complete?
      true
    end

    def type
      concrete_procedure.return_type
    end

    def type_check
      @type_check ||= ConcreteProcedureCallTypeCheck.new(concrete_procedure, argument_type_inferences)
    end

    def work!; end

    def to_s
      ''
    end
  end
end
