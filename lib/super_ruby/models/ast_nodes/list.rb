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
      delegate :each, :[], :size, to: :children

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

      def evaluate!(scope)
        if children.size == 3 && children.first.is_define?
          children[1].evaluate!(Scope.new(scope))
          identifier = children[1].value
          raise "invalid identifier: #{identifier}" unless identifier.kind_of?(Values::Identifier)
          scope.define! identifier, children[2]
        end
      end

      def is_define?
        false
      end
    end
  end
end
