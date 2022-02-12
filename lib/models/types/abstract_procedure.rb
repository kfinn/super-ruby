module Types
  class AbstractProcedure
    include BaseType

    def initialize(argument_names, body)
      @argument_names = argument_names
      @body = body
      @workspace = Workspace.current_workspace
      @super_binding = @workspace.current_super_binding
    end
    attr_reader :argument_names, :body, :workspace, :super_binding

    def delivery_strategy_for_message(message)
      case message
      when 'specialize'
        :static
      else
        super
      end
    end

    def message_send_result_typing(message, argument_typings)
      case message
      when 'call'
        raise "invalid arguments count to AbstractProceudure#call. Expected #{argument_names.size}, got #{argument_typings.size}" unless argument_typings.size == argument_names.size
        Jobs::AbstractProcedureCall.new(self, argument_typings)
      when 'specialize'
        raise "invalid arguments count to AbstractProcedure#specialize. Expected 1, got #{argument_typings.size}" unless argument_typings.size == 1
        Jobs::ExplicitProcedureSpecialization.new(self, argument_typings.first)
      else
        super
      end
    end

    def build_message_send_bytecode!(typing)
      case typing.message
      when 'call'
        Workspace.current_workspace.current_bytecode_builder << Opcodes::DISCARD

        implicit_procedure_specialization = cached_implicit_procedure_specialization_for_argument_types(
          typing.argument_typings.map(&:type)
        )

        Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_workspace.current_bytecode_builder << implicit_procedure_specialization.concrete_procedure_instance.bytecode_pointer
        Workspace.current_workspace.current_bytecode_builder << Opcodes::CALL
        Workspace.current_workspace.current_bytecode_builder << typing.argument_typings.size
      when 'specialize'
        (typing.argument_typings.size + 1).times do
          Workspace.current_workspace.current_bytecode_builder << Opcodes::DISCARD
        end
        
        implicit_procedure_specialization = cached_implicit_procedure_specialization_for_argument_types(
          typing.argument_typings.first.value.argument_types
        )

        Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_workspace.current_bytecode_builder << implicit_procedure_specialization.concrete_procedure_instance.bytecode_pointer
      else
        super
      end
    end

    def cached_implicit_procedure_specialization_for_argument_types(argument_types)
      cached_implicit_procedure_specializations_by_argument_types[argument_types]
    end

    def define_implicit_procedure_specialization(implicit_procedure_specialization)
      if implicit_procedure_specialization.argument_types.in? cached_implicit_procedure_specializations_by_argument_types
        raise "duplicate procedure specialization for #{self}: #{implicit_procedure_specialization.argument_types.to_s}" 
      end
      cached_implicit_procedure_specializations_by_argument_types[implicit_procedure_specialization.argument_types] = implicit_procedure_specialization
    end

    def to_s
      "(AbstractProcedure (#{argument_names.size.times.map { "?" }.join(", ")}) ?)"
    end

    private

    def cached_implicit_procedure_specializations_by_argument_types
      @cached_implicit_procedure_specializations_by_argument_types ||= {}
    end
  end
end
