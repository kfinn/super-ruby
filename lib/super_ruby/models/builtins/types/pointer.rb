module SuperRuby
  module Builtins
    module Types
      class Pointer
        include TypeBase

        methods Methods::Free, Methods::Dereference, Methods::Equals
      end
    end
  end
end
