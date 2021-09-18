module SuperRuby
  module Builtins
    module Methods
      class Assign
        include MethodBase

        names '='
        arguments :value

        body do |super_self, scope, memory, value:|
          super_self.assign! value
        end
      end
    end
  end
end
