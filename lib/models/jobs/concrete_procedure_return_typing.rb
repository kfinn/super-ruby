module Jobs
  class ConcreteProcedureReturnTyping
    prepend BaseJob

    def initialize(procedure_specialization)
      @procedure_specialization = procedure_specialization
      procedure_specialization.add_downstream(self)
    end
    attr_reader :procedure_specialization
    delegate :return_typing, to: :procedure_specialization
    delegate :complete?, to: :return_typing, allow_nil: true
    delegate :type, to: :return_typing

    def work!; end
  end
end
