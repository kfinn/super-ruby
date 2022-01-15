module AstNodes
  module BaseAstNode
    extend ActiveSupport::Concern

    def define?
      (
        list? &&
        size == 3 &&
        first.atom? &&
        first.text == 'define' &&
        second.atom?
      )
    end

    def procedure_definition?
      (
          list? &&
          size == 3 &&
          first.atom? &&
          first.text == 'procedure' &&
          second.list? &&
          second.all?(&:atom?)
      )
    end

    def message_send?
      (
        list? &&
        size >= 2 &&
        second.atom?
      )
    end

    def integer_literal?
      (
        atom? &&
        text.match(/^(0|-?[1-9](\d)*)$/)
      )
    end

    def boolean_literal?
      (
        atom? &&
        text.in?(['true', 'false'])
      )
    end

    def if?
      (
        list? &&
        first.atom? &&
        first.text == 'if' &&
        size.in?(3..4)
      )
    end

    def sequence?
      (
        list? &&
        first.atom? &&
        first.text == 'sequence' &&
        second.list?
      )
    end

    def identifier?
      kind_of? Atom
    end
  end
end
