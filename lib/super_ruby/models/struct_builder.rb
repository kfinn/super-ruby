module SuperRuby
  class StructBuilder
    class Member
      include ActiveModel::Model
      attr_accessor :name, :type, :default_value

      def to_struct_member
        Builtins::Types::Struct::Member.new(name, type.llvm_symbol)
      end
    end

    class VarMethod
      def initialize(struct_builder)
        @struct_builder = struct_builder
      end
      attr_reader :struct_builder

      def super_send!(list)
        struct_builder.add_member(
          Member.new(
            name: list.second.text,
            type: list.third.to_bytecode_chunk!,
            default_value: list.fourth&.to_bytecode_chunk!
          )
        )
        Values::Void.instance
      end

      def force!
        true
      end
    end

    def initialize(scope)
      @scope = scope
    end

    attr_reader :scope

    def resolve(identifier)
      if identifier == "var"
        var_method
      else
        scope.resolve(identifier)
      end
    end

    def to_bytecode_chunk!
      type = Builtins::Types::Struct.new(members.map(&:to_struct_member))
      initializer = Workspace.current_llvm_module.functions.add(
        BytecodeSymbolId.next("struct_initializer"),
        [LLVM::Pointer(type.to_llvm_type)],
        LLVM.Void
      )

      initializer_main_basic_block = initializer.basic_blocks.append
      Scope.with_current_scope(Scope.empty) do
        Workspace.with_current_basic_block(initializer_main_basic_block) do
          members.each_with_index do |member, index|
            if member.default_value.present?
              Workspace.current_basic_block_builder do |current_basic_block_builder|
                member_pointer = current_basic_block_builder.gep(
                  initializer.params.first,
                  [LLVM.Int(0), LLVM.Int(index)]
                )
                current_basic_block_builder.store(
                  member.default_value.llvm_symbol,
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
        value_type: Builtins::Types::Type,
        llvm_symbol: type
      )
    end

    def add_member(member)
      members << member
    end

    def members
      @members ||= []
    end

    def var_method
      @var_method ||= VarMethod.new(self)
    end
  end
end
