module Jobs
  class ConcreteProcedureCallTyping
    prepend BaseJob

    def initialize(
      concrete_procedure,
      argument_typings
    )
      @concrete_procedure = concrete_procedure
      @argument_typings = argument_typings
      argument_typings.each do |argument_typing|
        argument_typing.add_downstream(self)
      end
    end
    attr_reader :concrete_procedure, :argument_typings
    attr_accessor :validated
    alias validated? validated
    alias complete? validated?

    def type
      concrete_procedure.return_type
    end

    def upstream_typings_complete?
      argument_typings.all?(&:complete?)
    end

    def work!
      return unless upstream_typings_complete?
      return if validated?

      self.validated = true
      invalid = false
      argument_typings.each_with_index do |argument_typing, argument_index|
        if argument_typing.type != concrete_procedure.argument_types[argument_index]
          invalid = true
        end
      end
      if invalid
        raise "invalid arguments to concrete procedure\n\texpected #{concrete_procedure.argument_types.map(&:to_s.join(", "))})\n\tgot #{actual_types.map(&:to_s.join(", "))}"
      end
    end
  end
end
