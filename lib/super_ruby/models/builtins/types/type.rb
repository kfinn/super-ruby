module SuperRuby
  module Builtins
    module Types
      class Type
        include TypeBase

        methods Methods::New

        def to_llvm_type
          LLVM::Int8
        end
      end
    end
  end
end
