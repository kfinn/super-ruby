module Types
  class AbstractProcedure
    def initialize(argument_names, body)
      @argument_names = argument_names
      @body = body
      @workspace = Workspace.current_workspace
      @super_binding = @workspace.current_super_binding
    end
    attr_reader :argument_names, :body, :workspace, :super_binding

    def message_send_result_typing(message, argument_typings)
      case message
      when 'call'
        raise "Invalid arguments count: expected #{argument_names.size}, but got #{argument_typings.size}" unless argument_typings.size == argument_names.size

        procedure_specialization = Jobs::ProcedureSpecialization.new(
          self,
          argument_names.zip(argument_typings).to_h
        )

        Jobs::ConcreteProcedureReturnTyping.new(
          procedure_specialization
        )
      else
        raise "invalid message: #{message}"
      end
    end

    def cached_concrete_procedure_for_argument_types(argument_types)
      cached_concrete_procedures_by_argument_types[argument_types]
    end

    def define_concrete_procedure(concrete_procedure)
      cached_concrete_procedures_by_argument_types[concrete_procedure.argument_types] = concrete_procedure
    end

    private

    def cached_concrete_procedures_by_argument_types
      @cached_concrete_procedures_by_argument_types ||= {}
    end
  end
end
