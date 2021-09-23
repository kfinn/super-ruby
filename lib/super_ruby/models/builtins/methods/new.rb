module SuperRuby
  module Builtins
    module Methods
      class New
        include MethodBase

        def to_bytecode_chunk!(
          llvm_module,
          llvm_basic_block,
          super_self_bytecode_chunk,
          arguments_bytecode_chunks
        )
          type = super_self_bytecode_chunk.llvm_symbol
          llvm_symbol = llvm_basic_block.malloc(type.to_llvm_type)
          Values::BytecodeChunk.new(
            value_type: Types::Pointer.new(type),
            llvm_symbol: llvm_symbol
          )
        end
      end
    end
  end
end
