module SuperRuby
  module Builtins
    module Macros
      class Define < MacroBase
        def call!(list, scope, memory)
          identifier = list.second.text
          
          value = list.third.evaluate! scope.spawn, memory

          scope.define! identifier, value
          Values::Void.instance
        end
      end
    end
  end
end
