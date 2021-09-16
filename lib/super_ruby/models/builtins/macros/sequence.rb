module SuperRuby
  module Builtins
    module Macros
      class Sequence < MacroBase
        def call!(list, scope, memory)
          list_values = list.second.map { |child| child.evaluate! scope, memory }
          list_values.last
        end
      end
    end
  end
end
