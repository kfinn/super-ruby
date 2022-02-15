module Jobs
  class ConcreteProcedureLiteralEvaluation
    prepend BaseJob

    def initialize(argument_typed_evaluations, return_typed_evaluation)
      @argument_typed_evaluations = argument_typed_evaluations
      @return_typed_evaluation = return_typed_evaluation

      @argument_typed_evaluations.each do |argument_typed_evaluation|
        argument_typed_evaluation.add_downstream(self)
      end
      @return_typed_evaluation.add_downstream(self)
    end

    attr_reader :argument_typed_evaluations, :return_typed_evaluation
    attr_accessor :value

    def upstreams_complete?
      argument_typed_evaluations.all?(&:complete?) && return_typed_evaluation.complete?
    end

    def work!
      return unless upstreams_complete?

      self.value = Types::ConcreteProcedure.new(
        argument_typed_evaluations.map(&:value),
        return_typed_evaluation.value
      )
    end

    def type
      Types::Type.instance
    end

    def type_check
      ImmediateTypeCheck.success
    end

    def complete?
      value.present?
    end

    def to_s
      "(ConcreteProcedure (#{argument_typed_evaluations.map(&:to_s).join(" ")}) #{return_typed_evaluation.to_s})"
    end
  end
end
