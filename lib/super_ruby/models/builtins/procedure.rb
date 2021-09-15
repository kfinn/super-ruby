module SuperRuby
  module Builtins
    class Procedure < BaseBuiltin
      def self.match?(list)
        super && list.size == 3
      end

      def evaluate!(scope, _memory)
        Values::Procedure.new(list.second, list.third, scope)
      end
    end
  end
end
