class ProcedureSpecializationsCollection
  def procedure_specialization_for(ast_node, argument_typings_by_name)
    workspace = Workspace.current_workspace
    super_binding =
      argument_typings_by_name
      .each_with_object(
        workspace
        .current_super_binding
        .spawn
      ) do |(argument_name, argument_typing), super_binding|
        super_binding.set_typing(
          argument_name,
          argument_typing
        )
      end

    typing = workspace.with_current_super_binding(super_binding) do
      workspace.typing_for(body)
    end
  end

  private

  def storage
    @storage ||= {}
  end
end
