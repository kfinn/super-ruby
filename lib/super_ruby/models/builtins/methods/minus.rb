module SuperRuby
  module Builtins
    module Methods
      class Minus
        include MethodBase
        arguments :other

        names '-'

        body do |super_self, scope, _memory, other:|
          raise "Invalid -: mismatched types (#{super_self.type} + #{other.type})" unless super_self.type == other.type
          Values::Concrete.new(
            super_self.type,
            super_self.value - other.value
          )
        end
      end
    end
  end
end
