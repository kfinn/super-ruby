module SuperRuby
  module Builtins
    module Methods
      class Size
        include MethodBase

        body do |super_self, scope, _memory|
          raise "Invalid size_of: cannot find size of something that is not of type Type (#{super_self.type.to_s})" unless super_self.type == Builtins::Types::Type.instance
          Values::Concrete.new(
            Builtins::Types::Integer.instance,
            super_self.value.size
          )
        end
      end
    end
  end
end
