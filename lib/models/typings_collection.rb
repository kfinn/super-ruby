class TypingsCollection
  def initialize(workspace)
    @workspace = workspace
  end

  attr_reader :workspace

  def typing_for(ast_node)
    storage[ast_node] ||= ast_node.spawn_typing
  end

  private

  def storage
    @storage ||= {}
  end
end
