class TypeInferencesCollection
  def initialize(workspace)
    @workspace = workspace
  end

  attr_reader :workspace

  def type_inference_for(ast_node)
    return storage[ast_node] if ast_node.in? storage

    puts "spawning type inference for #{ast_node.s_expression}" if ENV["DEBUG"]
    type_inference = ast_node.spawn_type_inference
    puts "spawned type inference for #{ast_node.s_expression}: #{type_inference.to_s}" if ENV["DEBUG"]
    storage[ast_node] = type_inference
  end

  private

  def storage
    @storage ||= {}
  end
end
