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

      def evaluate!(scope)
        raise "unable to evaluate an empty list" if children.size == 0
        matching_builtin = Builtins.all.find { |builtin| builtin.match? self }
        return matching_builtin.new(self).evaluate!(scope) if matching_builtin.present?

        matching_procedure = children.first.evaluate! scope
        if matching_procedure.present?
          argument_values = children[1..-1].map do |argument_value_expression|
            argument_value_expression.evaluate! scope.spawn
          end
          return matching_procedure.call!(argument_values)
        end

        raise "unable to evaluate list #{to_s} within scope #{scope}"
      end

      def to_s
        "(#{map(&:to_s).join(" ")})"
      end
    end
  end
end
