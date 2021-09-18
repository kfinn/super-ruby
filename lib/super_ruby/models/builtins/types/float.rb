module SuperRuby
  module Builtins
    module Types
      class Float
        include TypeBase

        methods Methods::Plus, Methods::Minus, Methods::Equals
      end
    end
  end
end
