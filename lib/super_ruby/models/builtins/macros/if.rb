module SuperRuby
  module Builtins
    module Macros
      class If 
        include MacroBase

        def to_bytecode_chunk!(list, scope, llvm_module, llvm_basic_block)
          condition_basic_block = llvm_basic_block.insert_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_condition"))
          then_basic_block = llvm_basic_block.insert_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_then"))
          else_basic_block = llvm_basic_block.insert_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_else"))
          result_basic_block = llvm_basic_block.insert_block.parent.basic_blocks.append(BytecodeSymbolId.next("if_result"))

          llvm_basic_block.br(condition_basic_block)

          condition_basic_block.build do |condition_basic_block_builder|
            condition_bytecode_chunk = list.second.to_bytecode_chunk! scope.spawn, llvm_module, condition_basic_block_builder
            condition_comparison_bytecode_chunk = condition_basic_block_builder.icmp(
              :ne,
              condition_bytecode_chunk,
              condition_bytecode_chunk.value_type.call(0)
            )
            condition_basic_block_builder.cond(
              condition_comparison_bytecode_chunk,
              then_basic_block,
              else_basic_block
            )
          end
          
          then_bytecode_chunk = nil
          then_basic_block.build do |then_basic_block_builder|
            then_bytecode_chunk = list.third.to_bytecode_chunk! scope.spawn, llvm_module, then_basic_block_builder
            then_basic_block_builder.br(result_basic_block)
          end

          else_bytecode_chunk = nil
          else_basic_block.build do |else_basic_block_builder|
            else_bytecode_chunk = list.fourth.to_bytecode_chunk! scope.spawn, llvm_module, else_basic_block_builder
            else_basic_block_builder.br(result_basic_block)
          end

          raise "mismatched then/else branch values: #{then_bytecode_chunk.value_type} vs. #{else_bytecode_chunk.value_type}" unless then_bytecode_chunk.value_type == else_bytecode_chunk.value_type
          
          llvm_symbol = nil
          result_basic_block.build do |result_basic_block_builder|
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
        # def call!(list, scope, memory)
        #   condition = list.second

        #   condition_value = condition.evaluate!(scope.spawn, memory)
        #   if condition_value.value != 0
        #     list.third.evaluate! scope, memory
        #   else
        #     list.fourth.evaluate! scope, memory
        #   end
        # end
      end
    end
  end
end
