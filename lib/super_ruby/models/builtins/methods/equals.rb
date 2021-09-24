module SuperRuby
  module Builtins
    module Methods
      class Equals
        include MethodBase

        arguments :other

        names '=='

        def to_bytecode_chunk!(
          super_self_bytecode_chunk,
          arguments_bytecode_chunks
        )
          llvm_symbol = Workspace.current_basic_block_builder.icmp(
            :eq,
            super_self_bytecode_chunk.llvm_symbol,
            arguments_bytecode_chunks.first.llvm_symbol
          )
          Values::BytecodeChunk.new(
            value_type: Types::Integer.instance,
            llvm_symbol: llvm_symbol
          )
        end
      end
    end
  end
end
