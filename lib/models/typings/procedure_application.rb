module Typings
  class ProcedureApplication
    def initialize(procedure_body, argument_typings)
      @procedure_body = procedure_body
      @argument_typings = argument_typings
    end

    def complete?
      result_typing.complete?
    end

    def result_typing
      @result_typing ||= Typing.from_ast_node(procedure_body)
    end

    def type
      result_typing.type
    end
  end
end
