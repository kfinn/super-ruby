module Jobs
  class ConcreteProcedureLiteralEvaluation
    prepend BaseJob

    def initialize(argument_evaluations, return_evaluation)
      @argument_evaluations = argument_evaluations
      @return_evaluation = return_evaluation

      @argument_evaluations.each do |argument_typed_evaluation|
        argument_typed_evaluation.add_downstream(self)
      end
      @return_evaluation.add_downstream(self)
    end

    attr_reader :argument_evaluations, :return_evaluation
    attr_accessor :value

    def upstreams_complete?
      argument_evaluations.all?(&:complete?) && return_evaluation.complete?
    end

    def work!
      return unless upstreams_complete?

      self.value = Types::ConcreteProcedure.new(
        argument_evaluations.map(&:value),
        return_evaluation.value
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
      "(ConcreteProcedure (#{argument_evaluations.map(&:to_s).join(" ")}) #{return_evaluation.to_s})"
    end
  end
end
