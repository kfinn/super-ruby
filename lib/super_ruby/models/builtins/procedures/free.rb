module SuperRuby
  module Builtins
    module Procedures
      class Free < ProcedureBase
        arguments :pointer

        body do |scope, memory, pointer:|
          raise "Invalid free: pointer must have type Pointer, given #{pointer.type}" unless pointer.type == Values::Type::POINTER
          memory.free(pointer.value)
          Values::Concrete.new(Values::Type::VOID, nil)
        end
      end
    end
  end
end
