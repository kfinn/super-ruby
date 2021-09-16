module SuperRuby
  module Builtins
    module Procedures
      class Dereference < ProcedureBase
        arguments :pointer

        body do |scope, memory, pointer:|
          raise "invalid dereference: pointer must have type Pointer, given #{pointer.type}" unless pointer.type == Values::Type::POINTER
          memory.get(pointer.value)
        end
      end
    end
  end
end
