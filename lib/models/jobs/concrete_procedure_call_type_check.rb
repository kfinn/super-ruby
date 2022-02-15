module Jobs
  class ConcreteProcedureCallTypeCheck
    prepend BaseJob

    def initialize(concrete_procedure, argument_types)
      @concrete_procedure = concrete_procedure
      @argument_types = argument_types
    end
    attr_reader :concrete_procedure, :argument_types

    def complete?
      true
    end

    def valid?
      validate!
      @valid
    end

    attr_writer :valid

    def validate!
      mismatched_arguments = []
      concrete_procedure.argument_types.zip(argument_types).each_with_index do |(expected_argument, actual_argument), index|
        mismatched_argument_indices << index if expected_argument != actual_argument
      end
      self.valid = mismatched_arguments.empty?
    end
  end
end
