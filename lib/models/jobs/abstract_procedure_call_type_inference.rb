module Jobs
  class AbstractProcedureCallTypeInference
    prepend BaseJob

    def initialize(abstract_procedure, argument_typings)
      @abstract_procedure = abstract_procedure
      @argument_typings = argument_typings
    end
    attr_reader :abstract_procedure, :argument_typings
    attr_accessor :implicit_procedure_specialization
    delegate :complete?, :concrete_procedure, to: :implicit_procedure_specialization

    def type
      concrete_procedure.return_type
    end

    def implicit_procedure_specialization
      @implicit_procedure_specialization ||=
        Jobs::ImplicitProcedureSpecialization.new(
          abstract_procedure,
          argument_typings
        ).tap do |built|
          built.add_downstream(self)
        end
    end

    def work!; end

    def to_s
      "((AbstractProcedure (#{abstract_procedure.argument_names.map { "?" }.join(" ")}) ?) call#{argument_typings.map { |argument_typing| " #{argument_typing.to_s}" }.join})"
    end
  end
end
