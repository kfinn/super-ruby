module SuperRuby
  module Builtins
    module Macros
      class If 
        include MacroBase

        def to_bytecode_chunk!(list)
          starting_scope = Scope.current_scope

          condition_basic_block = Workspace.current_basic_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_condition"))
          then_basic_block = Workspace.current_basic_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_then"))
          else_basic_block = Workspace.current_basic_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_else"))
          result_basic_block = Workspace.current_basic_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_result"))
          Workspace.current_basic_block_builder do |starting_llvm_basic_block_builder|
            starting_llvm_basic_block_builder.br(condition_basic_block)
          end

          condition_bytecode_chunk =
            Workspace.with_current_basic_block(condition_basic_block) do
              Scope.with_current_scope(starting_scope.spawn) do
                list.second.to_bytecode_chunk!
              end
            end
          condition_basic_block.build do |condition_basic_block_builder|
            condition_basic_block_builder.cond(
              condition_bytecode_chunk.llvm_symbol,
              then_basic_block,
              else_basic_block
            )
          end
          
          then_phi_source = nil
          then_bytecode_chunk =
            Workspace.with_current_basic_block(then_basic_block) do
              Scope.with_current_scope(starting_scope.spawn) do
                list.third.to_bytecode_chunk!.tap do
                  then_phi_source = Workspace.current_basic_block
                end
              end
            end
          then_phi_source.build do |then_phi_source_builder|
            then_phi_source_builder.br(result_basic_block)
          end

          else_phi_source = nil
          else_bytecode_chunk =
            Workspace.with_current_basic_block(else_basic_block) do
              Scope.with_current_scope(starting_scope.spawn) do
                list.fourth.to_bytecode_chunk!.tap do
                  else_phi_source = Workspace.current_basic_block
                end
              end
            end
          else_phi_source.build do |else_phi_source_builder|
            else_phi_source_builder.br(result_basic_block)
          end

          raise "mismatched then/else branch values: #{then_bytecode_chunk.value_type} vs. #{else_bytecode_chunk.value_type}" unless then_bytecode_chunk.value_type == else_bytecode_chunk.value_type
          
          llvm_symbol = nil
          result_basic_block.build do |result_basic_block_builder|
            llvm_symbol = result_basic_block_builder.phi(
              then_bytecode_chunk.value_type.to_llvm_type,
              {
                then_phi_source => then_bytecode_chunk.llvm_symbol,
                else_phi_source => else_bytecode_chunk.llvm_symbol
              }
            )
          end
          Workspace.current_basic_block = result_basic_block

          BytecodeChunk.new(
            value_type: then_bytecode_chunk.value_type,
            llvm_symbol: llvm_symbol
          )
        end
      end
    end
  end
end
