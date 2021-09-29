module SuperRuby
  module Builtins
    module Methods
      class Call
        def initialize(procedure_type)
          @procedure_type = procedure_type
        end
        attr_reader :procedure_type

        def to_bytecode_chunk!(super_self_bytecode_chunk, arguments_bytecode_chunks)
          llvm_symbol =
            Workspace
            .current_basic_block_builder do |current_basic_block_builder|
              current_basic_block_builder.call(
                super_self_bytecode_chunk.llvm_symbol,
                *arguments_bytecode_chunks.map(&:llvm_symbol)
              )
            end
          BytecodeChunk.new(
            value_type: procedure_type.return_type,
            llvm_symbol: llvm_symbol
          )
        end

        def force!
          true
        end
      end
    end
  end
end
