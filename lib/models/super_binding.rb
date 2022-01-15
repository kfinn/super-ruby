class SuperBinding
  def initialize(parent: nil, inherit_dynamic_locals: false)
    @parent = parent
    @inherit_dynamic_locals = inherit_dynamic_locals
  end

  attr_reader :parent, :inherit_dynamic_locals

  def fetch_typing(name, include_dynamic_locals: true)
    return dynamic_locals[name] if include_dynamic_locals && dynamic_locals.include?(name)
    return static_local_typings[name] if static_local_typings.include?(name)
    raise "unknown identifier: #{name}" unless parent.present?
    parent.fetch_typing(name, include_dynamic_locals: inherit_dynamic_locals)
  end

  def set_typing(name, typing)
    raise "attempting to redefine #{name}" if name.in? static_local_typings
    static_local_typings[name] = typing
  end

  def static_local_typings
    @static_local_typings ||= {}
  end

  def dynamic_locals
    @dynamic_locals ||= {}
  end

  def spawn(inherit_dynamic_locals: false)
    SuperBinding.new(parent: self, inherit_dynamic_locals: inherit_dynamic_locals)
  end
end
