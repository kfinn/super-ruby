class SuperBinding
  def initialize(
    parent: nil,
    inherit_dynamic_locals: false,
    static_locals: {},
    dynamic_local_typings: {},
    dynamic_local_values: {}
  )
    @parent = parent
    @inherit_dynamic_locals = inherit_dynamic_locals
    @static_locals = static_locals
    @dynamic_local_typings = dynamic_local_typings
    @dynamic_local_values = dynamic_local_values
  end

  attr_reader :parent, :inherit_dynamic_locals, :static_locals, :dynamic_local_typings, :dynamic_local_values

  def fetch_typing(name, include_dynamic_locals: true)
    return dynamic_local_typings[name] if include_dynamic_locals && dynamic_local_typings.include?(name)
    return static_locals[name] if static_locals.include?(name)
    raise "unknown identifier: #{name}" unless parent.present?
    parent.fetch_typing(name, include_dynamic_locals: inherit_dynamic_locals)
  end

  def fetch_value(name, include_dynamic_locals: true)
    return dynamic_local_values[name] if include_dynamic_locals && dynamic_local_values.include?(name)
    return static_locals[name].value if static_locals.include?(name)
    raise "unknown identifier: #{name}" unless parent.present?
    parent.fetch_value(name, include_dynamic_locals: inherit_dynamic_locals)
  end
  
  def set_static_typing(name, typing)
    validate_name(name)
    static_locals[name] = typing
  end

  def set_dynamic_typing(name, typing)
    validate_name(name)
    dynamic_local_typings[name] = typing
  end

  def set_dynamic_value(name, value)
    raise "attempting to set dynamic value for unbound name #{name}" unless name.in? dynamic_local_typings
    raise "attempting to redefine dynamic value for #{name}" unless name.in? dynamic_local_typings
    dynamic_local_values[name] = value
  end

  def validate_name(name)
    raise "attempting to redefine #{name}" if name.in? static_locals
    current_super_binding = self
    while current_super_binding.inherit_dynamic_locals
      raise "attempting to redefine #{name}" if name.in? dynamic_local_typings
      current_super_binding = current_super_binding.parent
    end
  end

  def spawn(inherit_dynamic_locals: false)
    SuperBinding.new(parent: self, inherit_dynamic_locals: inherit_dynamic_locals)
  end

  def dup
    SuperBinding.new(
      parent: self.parent,
      inherit_dynamic_locals: inherit_dynamic_locals,
      static_locals: static_locals.dup,
      dynamic_local_typings: dynamic_local_typings.dup,
      dynamic_local_values: dynamic_local_values.dup
    )
  end
end
