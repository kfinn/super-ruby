module SuperRuby
  module Builtins
    module Methods
      class Free
        include MethodBase

        body do |super_self, scope, memory|
          memory.free(super_self.value)
          Values::Concrete.new(Builtins::Types::Void.instance, nil)
        end
      end
    end
  end
end
