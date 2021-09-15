module SuperRuby
  module Builtins
    class Procedure < BaseBuiltin
      def self.match?(list)
        super && list.size == 3
      end

      def evaluate!(scope)
        Values::Procedure.new(list.second, list.third)
      end
    end
  end
end
