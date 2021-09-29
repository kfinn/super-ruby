module SuperRuby
  module Builtins
    module Macros
      class Struct
        class Builder
          def methods
            @methods ||= {
              "var" => nil
            }
          end

          def members
            @members ||= {}
          end

          def define!(identifier, value)
          end

          def resolve(identifier)
            methods.fetch(identifier) do
              members.fetch(identifier) do
                raise "unknown identifier: #{identifier}"
              end
            end
          end
        end

        include MacroBase

        def to_bytecode_chunk!(list)
          members = list.second.map do |var_list|            
            raise unless var_list.first.text == 'var'
            name = var_list.second.text
            type = var_list.third.to_bytecode_chunk!
            raise unless type.value_type == Types::Type.instance
            Types::Struct::Member.new(
              name,
              type.llvm_symbol
            )
          end

          type = Types::Struct.new(members)
          initializer = Workspace.current_llvm_module.functions.add(
            BytecodeSymbolId.next("struct_initializer"),
            [LLVM::Pointer(type.to_llvm_type)],
            LLVM.Void
          )

          initializer_main_basic_block = initializer.basic_blocks.append
          Scope.with_current_scope(Scope.empty) do
            Workspace.with_current_basic_block(initializer_main_basic_block) do
              list.second.map.with_index do |var_list, index|
                raise unless var_list.first.text == 'var'
                if var_list.fourth.present?
                  initial_value = var_list.fourth.to_bytecode_chunk!
                  Workspace.current_basic_block_builder do |current_basic_block_builder|
                    member_pointer = current_basic_block_builder.gep(
                      initializer.params.first,
                      [LLVM.Int(0), LLVM.Int(index)]
                    )
                    store_llvm_symbol = current_basic_block_builder.store(
                      initial_value.llvm_symbol,
                      member_pointer
                    )
                  end
                end
              end
              Workspace.current_basic_block_builder do |current_basic_block_builder|
                current_basic_block_builder.ret(nil)
              end
            end
          end
          type.initializer = initializer

          BytecodeChunk.new(
            value_type: Types::Type,
            llvm_symbol: type
          )
        end
      end
    end
  end
end
