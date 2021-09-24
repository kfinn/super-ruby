module SuperRuby
  module Builtins
    module Types
      class Integer
        include TypeBase

        size 8

        methods Methods::Plus, Methods::Equals
        # methods Methods::Plus, Methods::Minus, Methods::Equals

        def to_llvm_type
          LLVM::Int
        end
      end
    end
  end
end
