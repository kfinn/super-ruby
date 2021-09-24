module SuperRuby
  module AstNodes
    Atom = Struct.new(:token) do
      def self.from_tokens(tokens)
        new(tokens.next)
      end

      delegate :text, to: :token

      def id
        @id ||= BytecodeSymbolId.next("atom")
      end

      def to_bytecode_chunk!
        if /\A[0-9]([0-9_]*[0-9])?\Z/.match? text
          Values::BytecodeChunk.new(
            value_type: Builtins::Types::Integer.instance,
            llvm_symbol: LLVM::Int(text.to_i)
          )
        elsif /\A[0-9][0-9_]*\.[0-9_]*\Z/.match? text
          Values::BytecodeChunk.new(
            value_type: Builtins::Types::Float.instance,
            llvm_symbol: LLVM::Double(text.to_f)
          )
        elsif token.match.kind_of? TokenMatches::StringLiteral
          raise "unimplemented"
        else
          Scope.current_scope.resolve(text)
        end
      end
      
      def to_s
        text
      end
    end
  end
end
