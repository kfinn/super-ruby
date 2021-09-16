module SuperRuby
  module Builtins
    module Procedures
      class Minus < ProcedureBase
        arguments :lhs, :rhs

        names '-'

        body do |scope, _memory, lhs:, rhs:|
          raise "Invalid -: mismatched types (#{lhs.type} + #{rhs.type})" unless lhs.type == rhs.type
          Values::Concrete.new(
            lhs.type,
            lhs.value - rhs.value
          )
        end
      end
    end
  end
end
