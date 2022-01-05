class TypingsCollection
  def initialize(workspace)
    @workspace = workspace
  end

  attr_reader :workspace

  def typing_for(ast_node, super_binding=Workspace.current_workspace.current_super_binding)
    key = [ast_node, super_binding]
    storage[key] ||= Typing::from_ast_node(ast_node)
  end

  private

  def storage
    @storage ||= {}
  end
end
