module SuperRuby
  module Builtins
    module Types
      class Integer
        include TypeBase

        methods Methods::Plus, Methods::Minus, Methods::Equals
      end
    end
  end
end
