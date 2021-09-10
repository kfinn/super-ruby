module SuperRuby
  module Builtins
    class Base
      attr_reader :list
      delegate :children, to: :list

      def initialize(list)
        @list = list
      end

      def self.match?(list)
        first_child = list.first
        first_child.kind_of?(AstNodes::Atom) && first_child.text == atom_text
      end

      def self.atom_text
        name.split("::").last.underscore
      end
    end
  end
end
