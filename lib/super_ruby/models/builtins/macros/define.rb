module SuperRuby
  module Builtins
    module Macros
      class Define 
        include MacroBase
        def to_bytecode_chunk!(list)
          identifier = list.second.text

          bytecode_chunk = Scope.with_current_scope(Scope.current_scope.spawn) do
            list.third.to_bytecode_chunk!
          end
          Scope.current_scope.define! identifier, bytecode_chunk

          Values::Void.instance
        end
      end
    end
  end
end
