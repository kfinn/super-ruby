module Llvm
  class Function
    class << self
      def next_name_index
        @next_name_index ||= 0
      end

      def next_name_index=(next_name_index)
        @next_name_index = next_name_index
      end

      def generate_name!
        "function_#{next_name_index}".tap do
          self.next_name_index += 1
        end
      end
    end

    def initialize(concrete_procedure, name: nil)
      @name = name.present? ? name : generate_name!
      @concrete_procedure = concrete_procedure
    end
    attr_reader :name, :concrete_procedure, :entry_basic_block
    delegate :generate_name!, to: :class

    def to_s
      <<~LLVM
        define #{concrete_procedure.return_type.build_llvm!} @#{name}(#{arguments.map(&:to_s).join(', ')}) {
        #{basic_blocks.map(&:to_s).join("\n")}
        }
      LLVM
    end

    def basic_blocks
      @basic_blocks ||= [entry_basic_block]
    end

    def add_basic_block!
      BasicBlock.new(self).tap do |basic_block|
        basic_blocks << basic_block
      end
    end

    def entry_basic_block
      @entry_basic_block ||= BasicBlock.new(self)
    end

    def arguments
      @arguments ||= concrete_procedure.argument_types.map do |argument_type|
        Argument.new(argument_type, Register.create!)
      end
    end

    class Argument
      def initialize(type, register)
        @type = type
        @register = register
      end
      attr_reader :type, :register

      def to_s
        "#{type.build_llvm!} #{register.to_s}"
      end
    end
  end
end
