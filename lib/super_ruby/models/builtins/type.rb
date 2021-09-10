module SuperRuby
  module Builtins
    class Type < Base
      def match?(list)
        return false unless super && list.size == 3
      end

      def evaluate!(scope)
        size_value = list.second.evaluate! scope.spawn
        size_value.value

        instance_scope = scope.spawn
        list.third.evaluate! instance_scope
      end
    end
  end
end
