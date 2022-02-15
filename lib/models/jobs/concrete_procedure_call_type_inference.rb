module Jobs
  class ConcreteProcedureCallTypeInference
    prepend BaseJob

    def initialize(
      concrete_procedure,
      argument_type_inferences
    )
      @concrete_procedure = concrete_procedure
      @argument_type_inferences = argument_type_inferences
      argument_type_inferences.each do |argument_type_inference|
        argument_type_inference.add_downstream(self)
      end
    end
    attr_reader :concrete_procedure, :argument_type_inferences
    attr_accessor :validated
    alias validated? validated
    alias complete? validated?

    def type
      concrete_procedure.return_type
    end

    def upstream_type_inferences_complete?
      argument_type_inferences.all?(&:complete?)
    end

    def work!
      return unless upstream_type_inferences_complete?
      return if validated?

      self.validated = true
      invalid = false
      argument_type_inferences.each_with_index do |argument_type_inference, argument_index|
        if argument_type_inference.type != concrete_procedure.argument_types[argument_index]
          invalid = true
        end
      end
      if invalid
        raise "invalid arguments to concrete procedure\n\texpected #{concrete_procedure.argument_types.map(&:to_s.join(", "))})\n\tgot #{actual_types.map(&:to_s.join(", "))}"
      end
    end
  end
end
