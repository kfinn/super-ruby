module SuperRuby
  module Builtins
    module Types
      class Void
        include TypeBase

        def to_llvm_type
          LLVM.Void
        end
      end
    end
  end
end
