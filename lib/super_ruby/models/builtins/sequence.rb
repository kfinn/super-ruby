module SuperRuby
  module Builtins
    class Sequence < BaseBuiltin
      def self.match?(list)
        super && list.size == 2
      end

      def evaluate!(scope, memory)
        list_values = list.second.map { |child| child.evaluate! scope, memory }
        list_values.last
      end
    end
  end
end
