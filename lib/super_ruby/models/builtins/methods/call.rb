module SuperRuby
  module Builtins
    module Methods
      class Call
        include MethodBase
        
        def call!(super_self, list, caller_scope, memory)
          call_scope = caller_scope.extract_argument_values_for_method_call(
            super_self.value,
            list,
            caller_scope,
            memory
          )

          super_self.value.call! call_scope, memory
        end
      end
    end
  end
end
