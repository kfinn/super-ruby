module SuperRuby
  module AstNodes
    LIST_END_TEXTS_BY_LIST_START = {
      "{" => "}",
      "(" => ")",
      "[" => "]"
    }.freeze

    class List
      attr_reader :children

      include Enumerable
      delegate :each, :[], :first, :second, :third, :fourth, :size, to: :children

      def self.from_tokens(tokens)
        list_start = tokens.next
        expected_list_end_text = LIST_END_TEXTS_BY_LIST_START[list_start.text]
        raise "invalid list start: #{list_start.text}" unless expected_list_end_text.present?

        children = AstNode.from_tokens(tokens)
        list_end_token = tokens.next
        raise "mismatched list, encountered #{list_end_token.text} without matching indent" unless list_end_token.text == expected_list_end_text
        new(children)
      end

      def initialize(children)
        @children = children
      end

      BUILTINS = [
        Builtins::Define,
        Builtins::Send
      ].freeze

      def typecheck!(scope)
        raise "unable to evaluate an empty list" if children.size == 0
        matching_builtin = BUILTINS.find { |builtin| builtin.match? self }
        raise "unable to evaluate list #{self.children}" unless matching_builtin.present?
        matching_builtin.new(self).typecheck!(scope)
      end

      def evaluate!(scope)
        raise "unable to evaluate an empty list" if children.size == 0
        matching_builtin = BUILTINS.find { |builtin| builtin.match? self }
        raise "unable to evaluate list #{self.children}" unless matching_builtin.present?
        matching_builtin.new(self).evaluate!(scope)
      end
    end
  end
end
