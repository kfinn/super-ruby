module SuperRuby
  module Builtins
    module Macros
      class Struct
        include MacroBase

        def to_bytecode_chunk!(list)
          struct_builder = StructBuilder.new(Scope.current_scope)
          Scope.with_current_scope(struct_builder) do
            list.second.each(&:to_bytecode_chunk!)
          end
          struct_builder.to_bytecode_chunk!
        end
      end
    end
  end
end
