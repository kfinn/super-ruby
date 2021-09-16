module SuperRuby
  module Builtins
    module Procedures
      class Assign < ProcedureBase
        arguments :destination, :value

        body do |scope, memory, destination:, value:|
          destination.assign! value
        end
      end
    end
  end
end
