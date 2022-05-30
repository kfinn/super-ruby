module SExpressions
  class List
    LIST_END_TEXTS_BY_LIST_START = {
      "{" => "}",
      "(" => ")",
      "[" => "]"
    }.freeze

    include BaseSExpression
    include DerivesEquality
    include Enumerable
    delegate :each, :[], :first, :second, :third, :fourth, :size, to: :children

    def initialize(children)
      @children = children
    end
    attr_reader :children
    alias state children

    def self.from_tokens(tokens)
      list_start = tokens.next
      expected_list_end_text = LIST_END_TEXTS_BY_LIST_START[list_start.text]
      raise "invalid list start: #{list_start.text}" unless expected_list_end_text.present?

      children = SExpression.from_tokens(tokens)
      list_end_token = tokens.next
      raise "mismatched list, encountered #{list_end_token.text} without matching indent" unless list_end_token.text == expected_list_end_text
      new(children)
    end

    def to_s(depth=0)
      if depth >= 4
        "..."
      else
        "(#{map { |child| child.to_s(depth + 1) }.join(" ")})"
      end
    end

    def list?
      true
    end

    def atom?
      false
    end
  end
end
