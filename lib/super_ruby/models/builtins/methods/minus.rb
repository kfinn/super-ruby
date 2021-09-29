module SuperRuby
  module Builtins
    module Methods
      class Minus
        include MethodBase
        
        arguments :other

        names '-'

        def to_bytecode_chunk!(
          super_self_bytecode_chunk,
          arguments_bytecode_chunks
        )
          llvm_symbol = Workspace.current_basic_block_builder do |current_basic_block_builder|
            current_basic_block_builder.sub(
              super_self_bytecode_chunk.llvm_symbol, *arguments_bytecode_chunks.map(&:llvm_symbol)
            )
          end
          BytecodeChunk.new(
            value_type: super_self_bytecode_chunk.value_type,
            llvm_symbol: llvm_symbol
          )
        end
      end
    end
  end
end
