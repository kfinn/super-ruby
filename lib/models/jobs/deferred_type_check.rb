module Jobs
  class DeferredTypeCheck
    prepend BaseJob

    def initialize(original_type_check, deferred_static_type_check)
      @original_type_check = original_type_check
      @deferred_static_type_check = deferred_static_type_check
    end
    attr_reader :original_type_check, :deferred_static_type_check
    attr_accessor :delegated
    alias complete? delegated

    def work!
      unless delegated
        self.delegated = true
        deferred_static_type_check.add_deferred_type_check(original_type_check)
      end
    end

    def valid?
      true
    end
    
    def errors
      []
    end
  end
end
