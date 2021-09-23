module SuperRuby
  module Builtins
    module Macros
      class Define 
        include MacroBase
        def to_bytecode_chunk!(list, scope, llvm_module, llvm_basic_block)
          identifier = list.second.text

          bytecode_chunk = list.third.to_bytecode_chunk! scope.spawn, llvm_module, llvm_basic_block

          scope.define! identifier, bytecode_chunk
          Values::Void.instance
        end
      end
    end
  end
end
