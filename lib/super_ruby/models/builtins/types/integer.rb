module SuperRuby
  module Builtins
    module Types
      class Integer
        include TypeBase

        method '+' do |super_self_bytecode_chunk, arguments_bytecode_chunks|
          llvm_symbol = Workspace.current_basic_block_builder do |current_basic_block_builder|
            current_basic_block_builder.add(
              super_self_bytecode_chunk.llvm_symbol, *arguments_bytecode_chunks.map(&:llvm_symbol)
            )
          end
          BytecodeChunk.new(
            value_type: super_self_bytecode_chunk.value_type,
            llvm_symbol: llvm_symbol
          )
        end

        method '-' do |super_self_bytecode_chunk, arguments_bytecode_chunks|
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

        method '==' do |super_self_bytecode_chunk, arguments_bytecode_chunks|
          llvm_symbol = Workspace.current_basic_block_builder do |current_basic_block_builder|
            current_basic_block_builder.icmp(
              :eq,
              super_self_bytecode_chunk.llvm_symbol,
              arguments_bytecode_chunks.first.llvm_symbol
            )
          end
          BytecodeChunk.new(
            value_type: instance,
            llvm_symbol: llvm_symbol
          )
        end

        def to_llvm_type
          LLVM::Int
        end
      end
    end
  end
end
