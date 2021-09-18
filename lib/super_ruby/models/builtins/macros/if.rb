module SuperRuby
  module Builtins
    module Macros
      class If 
        include MacroBase
        def call!(list, scope, memory)
          condition = list.second

          condition_value = condition.evaluate!(scope.spawn, memory)
          if condition_value.value != 0
            list.third.evaluate! scope, memory
          else
            list.fourth.evaluate! scope, memory
          end
        end
      end
    end
  end
end
