module SuperRuby
  module Builtins
    module Methods
      class Plus
        include MethodBase
        
        arguments :other

        names '+'

        body do |super_self, scope, _memory, other:|
          Values::Concrete.new(
            super_self.type,
            super_self.value + other.value
          )
        end
      end
    end
  end
end
