module SuperRuby
  module Builtins
    class Sequence < BaseBuiltin
      def self.match?(list)
        super && list.size == 2
      end

      def evaluate!(scope)
        list_values = list.second.map { |child| child.evaluate! scope }
        list_values.last
      end
    end
  end
end
