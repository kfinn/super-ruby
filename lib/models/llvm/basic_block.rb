module Llvm
  class BasicBlock
    class << self
      def next_name_index
        @next_name_index ||= 0
      end

      def next_name_index=(next_name_index)
        @next_name_index = next_name_index
      end

      def generate_name!
        "block_#{next_name_index}".tap do
          self.next_name_index += 1
        end
      end
    end

    delegate :<<, to: :instructions

    def initialize(function)
      @function = function
      @name = self.class.generate_name!
    end
    attr_reader :function, :name

    def instructions
      @instructions ||= []
    end

    def to_s
      <<~LLVM
      #{name}:
        #{instructions.map(&:to_s).join("\n")}
      LLVM
    end
  end
end
