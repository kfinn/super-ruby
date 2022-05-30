module Jobs
  class TypeInferenceWithDeferredTypeCheck
    prepend BaseJob

    def initialize(original_type_inference, deferred_static_type_check)
      @original_type_inference = original_type_inference
      @deferred_static_type_check = deferred_static_type_check
    end
    attr_reader :original_type_inference, :deferred_static_type_check
    delegate :complete?, :evaluation, :value, :type, to: :original_type_inference
    attr_accessor :added_downstream

    def work!
      unless added_downstream
        self.added_downstream = true
        original_type_inference.add_downstream self
      end
    end

    def type_check
      @type_check ||= DeferredTypeCheck.new(
        original_type_inference.type_check,
        deferred_static_type_check
      )
    end
  end
end
