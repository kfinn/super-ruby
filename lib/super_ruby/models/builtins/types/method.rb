module SuperRuby
  module Builtins
    module Types
      class Method
        include TypeBase

        def to_llvm_type
          LLVM::Function
        end
      end
    end
  end
end
