module SuperRuby
  module Values
    class BytecodeChunk
      include ActiveModel::Model

      attr_accessor :value_type, :llvm_symbol

      def super_send!(list)
        method = Scope.with_current_scope(value_type) do
          list.second.to_bytecode_chunk!
        end

        argument_value_bytecode_chunks = list[2..-1].map do |argument_expression|
          argument_expression.to_bytecode_chunk!
        end

        method.to_bytecode_chunk! self, argument_value_bytecode_chunks
      end

      def to_bytecode_chunk!
        self
      end

      def to_s
        "(bytecode #{value_type} #{llvm_symbol})"
      end
    end
  end
end
