module Types
  class AbstractProcedure
    def initialize(argument_names, body)
      @argument_names = argument_names
      @body = body
      @workspace = Workspace.current_workspace
      @super_binding = @workspace.current_super_binding
    end
    attr_reader :argument_names, :body, :workspace, :super_binding

    def delivery_strategy_for_message(message)
      if message == 'specialize'
        :static
      else
        :dynamic
      end
    end

    def message_send_result_typing(message, argument_typings)
      case message
      when 'specialize'
        raise "invalid arguments count to AbstractProcedure#specialize. Expected 1, got #{argument_typings.size}" unless argument_typings.size == 1
        Jobs::ProcedureSpecialization.new(self, argument_typings.first)
      else
        raise "invalid message: #{message}"
      end
    end

    def build_message_send_bytecode!(typing)
      case typing.message
      when 'specialize'
        (typing.argument_typings.size + 1).times do
          Workspace.current_workspace.current_bytecode_builder << Opcodes::DISCARD
        end
        
        procedure_specialization = cached_procedure_specialization_for_concrete_procedure(
          typing.argument_typings.first.value
        )

        Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_workspace.current_bytecode_builder << procedure_specialization.concrete_procedure_instance.bytecode_pointer
      end
    end

    def cached_procedure_specialization_for_concrete_procedure(concrete_procedure)
      cached_procedure_specializations_by_concrete_procedure[concrete_procedure]
    end

    def define_procedure_specialization(procedure_specialization)
      if procedure_specialization.concrete_procedure.in? cached_procedure_specializations_by_concrete_procedure
        raise "duplicate procedure specialization for #{self}: #{procedure_specialization.concrete_procedure.to_s}" 
      end
      cached_procedure_specializations_by_concrete_procedure[procedure_specialization.concrete_procedure] = procedure_specialization
    end

    def to_s
      "(#{argument_names.size.times.map { "?" }.join(", ")}) -> ?"
    end

    private

    def cached_procedure_specializations_by_concrete_procedure
      @cached_procedure_specializations_by_concrete_procedure ||= {}
    end
  end
end
