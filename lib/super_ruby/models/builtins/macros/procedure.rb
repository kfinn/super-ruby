module SuperRuby
  module Builtins
    module Macros
      class Procedure < MacroBase
        def call!(list, scope, _memory)
          Values::Procedure.new(list.second.map(&:text), list.third, scope)
        end
      end
    end
  end
end
