module SuperRuby
  module Builtins
    module Methods
      class Write
        include MethodBase

        def to_bytecode_chunk!(
          super_self_bytecode_chunk,
          arguments_bytecode_chunks
        )
          llvm_symbol =
            Workspace
            .current_basic_block_builder do |current_basic_block_builder|
              current_basic_block_builder.store(
                arguments_bytecode_chunks.first.llvm_symbol,
                super_self_bytecode_chunk.llvm_symbol
              )
            end
            
          BytecodeChunk.new(
            value_type: Types::Void,
            llvm_symbol: llvm_symbol
          )
        end
      end
    end
  end
end
