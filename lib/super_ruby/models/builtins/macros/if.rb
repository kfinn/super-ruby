module SuperRuby
  module Builtins
    module Macros
      class If 
        include MacroBase

        def to_bytecode_chunk!(list)
          starting_llvm_basic_block = Workspace.current_basic_block_builder
          starting_scope = Scope.current_scope

          condition_basic_block = starting_llvm_basic_block.insert_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_condition"))
          then_basic_block = starting_llvm_basic_block.insert_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_then"))
          else_basic_block = starting_llvm_basic_block.insert_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_else"))
          result_basic_block = starting_llvm_basic_block.insert_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_result"))

          starting_llvm_basic_block.br(condition_basic_block)

          condition_basic_block.build do |condition_basic_block_builder|
            Workspace.with_current_basic_block_builder(condition_basic_block_builder) do
              Scope.with_current_scope(starting_scope.spawn) do
                condition_bytecode_chunk = list.second.to_bytecode_chunk!
                condition_basic_block_builder.cond(
                  condition_bytecode_chunk.llvm_symbol,
                  then_basic_block,
                  else_basic_block
                )
              end
            end
          end
          
          then_bytecode_chunk = nil
          then_basic_block.build do |then_basic_block_builder|
            Workspace.with_current_basic_block_builder(then_basic_block_builder) do
              Scope.with_current_scope(starting_scope.spawn) do
                then_bytecode_chunk = list.third.to_bytecode_chunk!
                then_basic_block_builder.br(result_basic_block)
              end
            end
          end

          else_bytecode_chunk = nil
          else_basic_block.build do |else_basic_block_builder|
            Workspace.with_current_basic_block_builder(else_basic_block_builder) do
              Scope.with_current_scope(starting_scope.spawn) do
                else_bytecode_chunk = list.fourth.to_bytecode_chunk!
                else_basic_block_builder.br(result_basic_block)
              end
            end
          end

          raise "mismatched then/else branch values: #{then_bytecode_chunk.value_type} vs. #{else_bytecode_chunk.value_type}" unless then_bytecode_chunk.value_type == else_bytecode_chunk.value_type
          
          llvm_symbol = nil
          result_basic_block.build do |result_basic_block_builder|
            Workspace.current_basic_block_builder = result_basic_block_builder
            llvm_symbol = result_basic_block_builder.phi(
              then_bytecode_chunk.value_type.to_llvm_type,
              {
                then_basic_block => then_bytecode_chunk,
                else_basic_block => else_bytecode_chunk
              }
            )
          end

          BytecodeChunk.new(
            value_type: then_bytecode_chunk.value_type,
            llvm_symbol: llvm_symbol
          )
        end
      end
    end
  end
end
