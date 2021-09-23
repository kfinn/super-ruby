module SuperRuby
  module Values
    class BytecodeChunk
      include ActiveModel::Model

      attr_accessor :value_type, :llvm_symbol

      def super_send!(list, scope, llvm_module, llvm_basic_block)
        method = list.second.to_bytecode_chunk! value_type, llvm_module, llvm_basic_block
        argument_value_bytecode_chunks = list[2..-1].map do |argument_expression|
          argument_expression.to_bytecode_chunk! scope, llvm_module, llvm_basic_block
        end

        method.to_bytecode_chunk! llvm_module, llvm_basic_block, self, argument_value_bytecode_chunks
      end

      def to_bytecode_chunk!(scope, llvm_module, llvm_basic_block)
        self
      end

      def to_s
        "(bytecode #{value_type} #{llvm_symbol})"
      end
    end
  end
end
