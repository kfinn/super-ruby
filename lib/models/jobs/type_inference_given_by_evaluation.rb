module Jobs
  class TypeInferenceGivenByEvaluation
    prepend BaseJob

    def initialize(evaluation)
      @evaluation = evaluation
    end
    attr_reader :evaluation
    attr_accessor :added_downstream, :added_second_downstream

    def complete?
      added_downstream && evaluation.complete? && evaluation.evaluation.complete?
    end

    def work!
      if !added_downstream
        self.added_downstream = true
        evaluation.add_downstream self
      end
      return unless evaluation.complete?

      if !added_second_downstream
        self.added_second_downstream = true
        evaluation.evaluation.add_downstream self
      end
    end
    
    def type
      evaluation.value
    end

    def type_check
      @type_check ||= TypeCheck.new(self)
    end

    class TypeCheck
      prepend Jobs::BaseJob

      def initialize(type_inference)
        @type_inference = type_inference
        type_inference.add_downstream self
      end
      attr_reader :type_inference
      attr_accessor :valid, :validated
      alias valid? valid
      alias complete? validated

      def work!
        return unless type_inference.complete?

        self.validated = true
        self.valid = type_inference.type == Types::Type.instance
      end
    end

    def to_s
      "(type_inference_given_by_evaluation #{evaluation.to_s})"
    end
  end
end
