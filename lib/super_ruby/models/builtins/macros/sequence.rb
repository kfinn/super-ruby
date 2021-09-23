module SuperRuby
  module Builtins
    module Macros
      class Sequence 
        include MacroBase
        def to_bytecode_chunk!(list, scope, llvm_module, initial_llvm_basic_block)
          last_bytecode_chunk = nil

          list.second.each do |child| 
            initial_llvm_basic_block.insert_block.parent.basic_blocks.last.build do |current_llvm_basic_block|
              last_bytecode_chunk = child.to_bytecode_chunk! scope, llvm_module, current_llvm_basic_block
            end
          end

          last_bytecode_chunk
        end
      end
    end
  end
end
