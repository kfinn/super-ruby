module SuperRuby
  module Builtins
    class Define < BaseBuiltin
      def self.match?(list)
        super && list.size == 3
      end

      def evaluate!(scope)
        identifier = list.second.text
        value = list.third.evaluate! scope.spawn

        scope.define! identifier, value
        Values::Void.instance
      end
    end
  end
end
