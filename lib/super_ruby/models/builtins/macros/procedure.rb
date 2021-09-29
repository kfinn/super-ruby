module SuperRuby
  module Builtins
    module Macros
      class Procedure
        include MacroBase

        def to_bytecode_chunk!(list)
          arguments = Types::Procedure::ArgumentList.new(
            list.second.map do |argument_list|
              argument_name = argument_list.first.text
              argument_type_bytecode_chunk = argument_list.second.to_bytecode_chunk!

              Types::Procedure::Argument.new(
                argument_name,
                argument_type_bytecode_chunk.llvm_symbol
              )
            end
          )

          return_type_bytecode_chunk = list.third.to_bytecode_chunk!
          return_type = return_type_bytecode_chunk.llvm_symbol

          llvm_symbol = Workspace.current_llvm_module.functions.add(
            BytecodeSymbolId.next("procedure"),
            arguments.to_llvm_type,
            return_type.to_llvm_type
          )

          definition_scope = Scope.current_scope
          lazy_builder = lambda do
            call_scope = definition_scope.spawn
            llvm_symbol.params.zip(arguments).each do |llvm_argument, argument|
              llvm_argument.name = argument.name
              call_scope.define!(
                argument.name,
                BytecodeChunk.new(
                  value_type: argument.type,
                  llvm_symbol: llvm_argument
                )
              )
            end

            Scope.with_current_scope(call_scope) do
              body_basic_block = llvm_symbol.basic_blocks.append
              Workspace.with_current_basic_block(body_basic_block) do
                return_value_bytecode_chunk = list.fourth.to_bytecode_chunk!.tap(&:force!)
                return_value = return_value_bytecode_chunk.llvm_symbol
                Workspace.current_basic_block_builder do |current_basic_block_builder|
                  current_basic_block_builder.ret return_value
                end
              end
            end
          end

          BytecodeChunk.new(
            value_type: Builtins::Types::Procedure.new(arguments, return_type),
            llvm_symbol: llvm_symbol,
            lazy_builder: lazy_builder
          )
        end
      end
    end
  end
end
