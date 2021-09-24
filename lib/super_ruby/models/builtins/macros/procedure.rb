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
          ) do |llvm_function, *llvm_arguments|
            call_scope = Scope.current_scope.spawn
            llvm_arguments.zip(arguments).each do |llvm_argument, argument|
              llvm_argument.name = argument.name
              call_scope.define!(
                argument.name,
                Values::BytecodeChunk.new(
                  value_type: argument.type,
                  llvm_symbol: llvm_argument
                )
              )
            end

            Scope.with_current_scope(call_scope) do
              llvm_function.basic_blocks.append.build do |body|
                Workspace.with_current_basic_block_builder(body) do
                  return_value = list.fourth.to_bytecode_chunk!.llvm_symbol
                  Workspace.current_basic_block_builder.ret return_value
                end
              end
            end
          end

          Values::BytecodeChunk.new(
            value_type: Builtins::Types::Procedure.new(arguments, return_type),
            llvm_symbol: llvm_symbol
          )
        end
      end
    end
  end
end
