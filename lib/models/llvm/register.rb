module Llvm
  class Register
    class << self
      def next_register_index
        @next_register_index ||= 1
      end
      attr_writer :next_register_index
      
      def create!
        new("r#{next_register_index}").tap do |created|
          self.next_register_index += 1
          yield created if block_given?
        end
      end
    end

    def initialize(name)
      @name = name
    end
    attr_reader :name

    def to_s
      "%#{name}"
    end
  end
end
