module SuperRuby
  module Builtins
    module Procedures
      class Free < ProcedureBase
        arguments :pointer

        body do |scope, memory, pointer:|
          raise "Invalid free: pointer must have type Pointer, given #{pointer.type}" unless pointer.type == Builtins::Types::POINTER
          memory.free(pointer.value)
          Values::Concrete.new(Builtins::Types::VOID, nil)
        end
      end
    end
  end
end
