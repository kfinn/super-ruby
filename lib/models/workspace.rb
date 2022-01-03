class Workspace
  class << self
    attr_accessor :current_workspace

    def with_current_workspace(workspace)
      previous_workspace = self.current_workspace
      self.current_workspace = workspace
      yield
      self.current_workspace = previous_workspace
    end
  end

  def add_source_string(text)
    sources << SourceString.new(text)
  end

  def evaluate!
    self.class.with_current_workspace(self) do
      static_pass!
      dynamic_pass!
    end
  end

  def static_pass!
    sources_to_parse.each do |source|
      root_ast_nodes = AstNode.from_tokens(Lexer.new(source).each_token)
      root_ast_nodes.each do |root_ast_node|
        root_ast_nodes_by_source[source] = root_ast_node
        typings_by_ast_node[root_ast_node] = Typing.from_ast_node(root_ast_node)
      end
    end

    incomplete_typings = Set.new(typings_by_ast_node.values.reject(&:complete?))
    blocked = false
    while incomplete_typings.any? && !blocked
      blocked = true
      completable_typings = incomplete_typings.select(&:complete?)
      blocked = completable_typings.any?
      incomplete_typings -= completable_typings
    end

    untyped_ast_nodes = typings_by_ast_node.each_with_object(Set.new) do |(ast_node, typing), acc|
      acc << ast_node unless typing.complete?
    end
  end

  def dynamic_pass!

  end

  def last_source
    sources.last
  end

  def result_ast_node
    root_ast_nodes_by_source[last_source]
  end

  def result_typing
    typings_by_ast_node[result_ast_node]
  end

  def result_type
    result_typing.type
  end

  def result_value
    "unimplemented"
  end

  def current_super_binding
    @current_super_binding ||= root_super_binding
  end

  attr_writer :current_super_binding

  def with_current_super_binding(new_super_binding)
    previous_super_binding = self.current_super_binding
    self.current_super_binding = new_super_binding
    yield
    self.current_super_binding = previous_super_binding
  end

  def typings_by_ast_node
    @typings_by_ast_node ||= Typing.new_typings_by_ast_node
  end

  private
  
  def sources
    @sources ||= []
  end

  def next_source_to_parse_index
    root_ast_nodes_by_source.size
  end

  def sources_to_parse
    sources[next_source_to_parse_index..]
  end

  def root_ast_nodes_by_source
    @root_ast_nodes_by_source ||= {}
  end

  def root_super_binding
    @root_super_binding ||= SuperBinding.new({})
  end
end
