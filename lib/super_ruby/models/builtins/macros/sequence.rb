module SuperRuby
  module Builtins
    module Macros
      class Sequence 
        include MacroBase
        def to_bytecode_chunk!(list)
          list.second.map(&:to_bytecode_chunk!).last
        end
      end
    end
  end
end
