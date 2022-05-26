module Llvm
  class Register
    class << self
      def next_register_index
        @next_register_index ||= 1
      end
      attr_writer :next_register_index
      
      def create!
        new(next_register_index.to_s).tap do
          self.next_register_index += 1
        end
      end
    end

    def initialize(name)
      @name = name
    end

    def to_s
      "%#{name}"
    end
  end
end
