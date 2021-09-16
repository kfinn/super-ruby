module SuperRuby
  module Builtins
    module Procedures
      class Allocate < ProcedureBase
        arguments :size

        body do |scope, memory, size:|
          raise "Invalid allocate: size must have type Integer, given #{size.type}" unless size.type == Values::Type::INTEGER
          allocation_id = memory.allocate(size.value)
          Values::Concrete.new(
            Values::Type::POINTER,
            allocation_id
          )
        end
      end
    end
  end
end
