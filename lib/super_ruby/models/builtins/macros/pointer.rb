module SuperRuby
  module Builtins
    module Macros
      class Pointer
        def self.names
          ["Pointer"]
        end

        include MacroBase

        def to_bytecode_chunk!(list)
          target_bytecode_chunk = list.second.to_bytecode_chunk!
          BytecodeChunk.new(
            value_type: Builtins::Types::Type.instance,
            llvm_symbol: Builtins::Types::Pointer.new(
              target_bytecode_chunk.llvm_symbol
            )
          )
        end
      end
    end
  end
end

