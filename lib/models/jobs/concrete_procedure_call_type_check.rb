module Jobs
  class ConcreteProcedureCallTypeCheck
    prepend BaseJob

    def initialize(concrete_procedure, argument_type_inferences)
      @concrete_procedure = concrete_procedure
      @argument_type_inferences = argument_type_inferences
    end
    attr_reader :concrete_procedure, :argument_type_inferences
    attr_accessor :added_downstreams, :argument_type_checks, :validated, :valid

    def argument_types
      @argument_types ||= argument_type_inferences.map(&:type)
    end

    alias valid? valid
    alias complete? validated

    def work!
      if !added_downstreams
        argument_type_inferences.each do |argument_type_inference|
          argument_type_inference.add_downstream(self)
        end  
      end
      return unless argument_type_inferences.all?(&:complete?)

      if argument_type_checks.nil?
        self.argument_type_checks = argument_type_inferences.map(&:type_check)
        argument_type_checks.each do |argument_type_check|
          argument_type_check.add_downstream(self)
        end
      end
      return unless argument_type_checks.all?(&:complete?)

      self.validated = true
      mismatched_arguments = []
      concrete_procedure.argument_types.zip(argument_types).each_with_index do |(expected_argument, actual_argument), index|
        mismatched_argument_indices << index if expected_argument != actual_argument
      end
      self.valid = argument_type_checks.all?(&:valid?) && mismatched_arguments.empty?
    end
  end
end
