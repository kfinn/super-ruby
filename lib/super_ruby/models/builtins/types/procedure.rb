module SuperRuby
  module Builtins
    module Types
      class Procedure
        include TypeBase

        methods Methods::Call
      end
    end
  end
end
