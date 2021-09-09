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
        raise "unable to evaluate an empty list" if children.size == 0
        first_child = children.first
        first_child.evaluate! scope
        first_child_value = first_child.value
        first_child_value_keyword = first_child_value.to_keyword
        raise "unable to evaluate a list with non-keyword initial argument: #{first_child_value}" unless first_child_value_keyword.present?
        @value = 
          case first_child_value_keyword
          when 'define'
            second_child = children[1]
            second_child.evaluate! scope.spawn
            identifier = second_child.value
            raise "invalid identifier: #{identifier}" unless identifier.kind_of?(Values::Identifier)
            raise "invalid identifier: #{identifier}" if identifier.to_keyword.present?
            scope.define! identifier, children[2]
            nil
          when 'send'
            second_child = children[1]
            second_child.evaluate! scope.spawn
            identifier = second_child.value
            raise "invalid identifier: #{identifier}" unless identifier.kind_of?(Values::Identifier)
            raise "invalid identifier: #{identifier}" if identifier.to_keyword.present?
            result_expression = scope.resolve(identifier)
            result_expression.evaluate! scope.spawn
            result_expression.value
          else
            raise "invalid keyword: #{first_child_value_keyword}"
          end
      end

      def value
        raise "attempting to take the value of an unevaluated expression" unless instance_variable_defined?(:@value)
        @value
      end
    end
  end
end
