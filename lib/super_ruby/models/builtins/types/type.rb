module SuperRuby
  module Builtins
    module Types
      class Type
        include TypeBase

        method 'new' do |super_self_bytecode_chunk|
          type = super_self_bytecode_chunk.llvm_symbol
          llvm_symbol =
            Workspace
            .current_basic_block_builder do |current_basic_block_builder|
              current_basic_block_builder.malloc(type.to_llvm_type)
            end
          BytecodeChunk.new(
            value_type: Types::Pointer.new(type),
            llvm_symbol: llvm_symbol
          )
        end

        def to_llvm_type
          LLVM::Int8
        end
      end
    end
  end
end
