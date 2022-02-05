class TypingsCollection
  def initialize(workspace)
    @workspace = workspace
  end

  attr_reader :workspace

  def typing_for(ast_node)
    return storage[ast_node] if ast_node.in? storage

    typing = ast_node.spawn_typing
    puts "spawned typing for #{ast_node.s_expression}: #{typing}" if ENV["DEBUG"]
    storage[ast_node] = typing
  end

  private

  def storage
    @storage ||= {}
  end
end
