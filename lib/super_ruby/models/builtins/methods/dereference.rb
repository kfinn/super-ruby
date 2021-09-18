module SuperRuby
  module Builtins
    module Methods
      class Dereference
        include MethodBase

        body do |super_self, scope, memory|
          memory.get(super_self.value)
        end
      end
    end
  end
end
