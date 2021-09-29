module SuperRuby
  module Builtins
    module Types
      class Struct
        class Member
          delegate :to_llvm_type, to: :type

          def initialize(name, type)
            @name = name
            @type = type
          end

          attr_reader :name, :type
        end

        class Getter
          def initialize(member, index)
            @member = member
            @index = index
          end
          attr_reader :member, :index

          def force!
            true
          end

          def to_bytecode_chunk!(
            super_self_bytecode_chunk,
            arguments_bytecode_chunks
          )
            raise if arguments_bytecode_chunks.any?

            llvm_symbol = Workspace.current_basic_block_builder do |current_basic_block_builder|
              current_basic_block_builder.gep(super_self_bytecode_chunk.llvm_symbol, [LLVM.Int(index)])
            end

            BytecodeChunk.new(
              value_type: Pointer.new(member.type),
              llvm_symbol: llvm_symbol
            )
          end
        end

        def initialize(members)
          @members = members
        end

        attr_reader :members
        attr_accessor :initializer

        def pointer_methods
          @pointer_methods ||= members.each_with_index.with_object({}) do |member_and_index, acc|
            member = member_and_index.first
            index = member_and_index.second
            acc[member.name] = Getter.new(member, index)
          end
        end

        def methods
          {}
        end

        def resolve(identifier)
          methods.fetch(identifier) do
            raise "unknown identifier: #{identifier}"
          end
        end

        def to_llvm_type
          @llvm_type ||= LLVM::Struct(*members.map(&:to_llvm_type))
        end
      end
    end
  end
end
