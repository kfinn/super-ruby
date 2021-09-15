module SuperRuby
  module Builtins
    class If < BaseBuiltin
      def self.match?(list)
        super && list.size == 4
      end

      def evaluate!(scope, memory)
        condition = children.second

        condition_value = condition.evaluate!(scope.spawn, memory)
        if condition_value.value != 0
          children.third.evaluate! scope, memory
        else
          children.fourth.evaluate! scope, memory
        end
      end
    end
  end
end
