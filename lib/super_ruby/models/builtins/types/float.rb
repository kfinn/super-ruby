module SuperRuby
  module Builtins
    module Types
      class Float
        include TypeBase

        methods Methods::Plus
        # methods Methods::Plus, Methods::Minus, Methods::Equals

        def to_llvm_type
          LLVM::Double
        end
      end
    end
  end
end
