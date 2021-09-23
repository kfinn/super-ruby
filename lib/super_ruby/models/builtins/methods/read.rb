module SuperRuby
  module Builtins
    module Methods
      class Read
        include MethodBase

        def to_bytecode_chunk!(
          llvm_module,
          llvm_basic_block,
          super_self_bytecode_chunk,
          arguments_bytecode_chunks
        )
          Values::BytecodeChunk.new(
            value_type: super_self_bytecode_chunk.value_type.target_type,
            llvm_symbol: llvm_basic_block.load(super_self_bytecode_chunk.llvm_symbol)
          )
        end
      end
    end
  end
end
