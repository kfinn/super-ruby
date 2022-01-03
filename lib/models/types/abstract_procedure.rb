module Types
  class AbstractProcedure
    def initialize(procedure_definition)
      @procedure_definition = procedure_definition
    end

    def typing_for_message_send(message, argument_typings)
      raise unless message == 'send'
      raise unless argument_typings.size == procedure_definition.argument_names.size
      message_send_result_types_by_argument_typings[argument_typings.map(&:type)]
    end

    private

    def procedure_applications_by_argument_typings
      @procedure_applications_by_argument_typings
        ||= Hash.new do |hash, argument_types|
          ProcedureApplication.new()
        body_super_binding =
          procedure_definition
          .argument_names
          .zip(argument_types)
          .each_with_object(
            procedure_definition.super_binding.spawn
          ) do |(argument_name, argument_type), builder|
            builder.set(argument_name, argument_type)
          end
        
        Workspace.current_workspace.with_current_super_binding(body_super_binding) do
          ProcedureApplication.new(
            procedure_definition.body.dup,
            argument_typings
          )
        end
      end
    end
  end
end
