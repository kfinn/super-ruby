module SuperRuby
  module Builtins
    module Macros
      class Var
        include MacroBase

        def to_bytecode_chunk!(list)
          identifier = list.second.text

          type_bytecode_chunk = Scope.with_current_scope(Scope.current_scope.spawn) do
            list.third.to_bytecode_chunk!
          end

          initial_value_bytecode_chunk = nil
          if list.fourth.present?
            initial_value_bytecode_chunk = Scope.with_current_scope(Scope.current_scope.spawn) do
              list.fourth.to_bytecode_chunk!
            end
          end
          
          storage_type = type_bytecode_chunk.llvm_symbol
          raise if initial_value_bytecode_chunk.present? && storage_type != initial_value_bytecode_chunk.value_type
          llvm_symbol = Workspace.current_basic_block_builder do |current_basic_block_builder|
            current_basic_block_builder.alloca(storage_type.to_llvm_type).tap do |pointer|
              if initial_value_bytecode_chunk.present?
                current_basic_block_builder.store initial_value_bytecode_chunk.llvm_symbol, pointer 
              elsif storage_type.initializer.present?
                current_basic_block_builder.call(
                  storage_type.initializer,
                  pointer
                )
              end
            end
          end

          Scope.current_scope.define!(
            identifier,
            BytecodeChunk.new(
              value_type: Types::Pointer.new(storage_type),
              llvm_symbol: llvm_symbol
            )
          )

          Values::Void.instance
        end
      end
    end
  end
end
