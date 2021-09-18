module SuperRuby
  module Builtins
    module Macros
      class Procedure 
        include MacroBase
        def call!(list, scope, _memory)
          Values::Concrete.new(
            Types::Procedure.instance,
            Values::Procedure.new(list.second.map(&:text), list.third, scope)
          )
        end
      end
    end
  end
end
