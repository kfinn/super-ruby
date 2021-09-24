module SuperRuby
  module Builtins
    module Methods
      class Read
        include MethodBase

        def to_bytecode_chunk!(
          super_self_bytecode_chunk,
          arguments_bytecode_chunks
        )
          llvm_symbol =
            Workspace
            .current_basic_block_builder
            .load(super_self_bytecode_chunk.llvm_symbol)
            
          Values::BytecodeChunk.new(
            value_type: super_self_bytecode_chunk.value_type.target_type,
            llvm_symbol: llvm_symbol
          )
        end
      end
    end
  end
end
