module SuperRuby
  module Builtins
    module Procedures
      class SizeOf < ProcedureBase
        arguments :type

        body do |scope, _memory, type:|
          raise "Invalid size_of: cannot find size of something that is not of type Type (#{type.type.to_s})" unless type.type == Builtins::Types::TYPE
          Values::Concrete.new(
            Builtins::Types::INTEGER,
            type.value.size
          )
        end
      end
    end
  end
end
