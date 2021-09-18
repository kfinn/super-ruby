
module SuperRuby
  module Builtins
    module Methods
      class New
        include MethodBase

        body do |super_self, scope, memory|
          allocation_id = memory.allocate(super_self.value)
          Values::Concrete.new(
            Builtins::Types::Pointer.instance,
            allocation_id
          )
        end
      end
    end
  end
end
