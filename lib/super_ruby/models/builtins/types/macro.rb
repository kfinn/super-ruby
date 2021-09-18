module SuperRuby
  module Builtins
    module Types
      class Macro
        include TypeBase

        methods Methods::Call
      end
    end
  end
end
