module SuperRuby
  module Builtins
    module Methods
      class Write
        include MethodBase

        def to_bytecode_chunk!(
          llvm_module,
          llvm_basic_block,
          super_self_bytecode_chunk,
          arguments_bytecode_chunks
        )
          llvm_symbol = llvm_basic_block.store(
            arguments_bytecode_chunks.first.llvm_symbol,
            super_self_bytecode_chunk.llvm_symbol
          )
          Values::BytecodeChunk.new(
            value_type: Types::Void,
            llvm_symbol: llvm_symbol
          )
        end
      end
    end
  end
end
