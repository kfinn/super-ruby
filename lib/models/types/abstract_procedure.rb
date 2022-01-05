module Types
  class AbstractProcedure
    def initialize(argument_names, body)
      @argument_names = argument_names
      @body = body
    end
    attr_reader :argument_names, :body

    def message_send_result_typing(message, argument_typings)
      case message
      when 'call'
        raise "Invalid arguments count: expected #{argument_names.size}, but got #{argument_typings.size}" unless argument_typings.size == argument_names.size

        workspace = Workspace.current_workspace
        super_binding =
          argument_names
          .zip(argument_typings)
          .each_with_object(
            workspace
            .current_super_binding
            .spawn
          ) do |(argument_name, argument_typing), super_binding|
            super_binding.set(
              argument_name,
              argument_typing
            )
          end

        workspace.with_current_super_binding(super_binding) do
          workspace.typing_for(body)
        end
      else
        raise "invalid message: #{message}"
      end
    end
  end
end
