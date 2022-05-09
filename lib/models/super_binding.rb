class SuperBinding
  def initialize(
    parent:,
    inherit_dynamic_locals: false,
    static_locals: LocalsCollection.new,
    dynamic_local_type_inferences: LocalsCollection.new,
    dynamic_local_values: LocalsCollection.new
  )
    @parent = parent
    @inherit_dynamic_locals = inherit_dynamic_locals
    @static_locals = static_locals
    @dynamic_local_type_inferences = dynamic_local_type_inferences
    @dynamic_local_values = dynamic_local_values
  end

  attr_reader :parent, :inherit_dynamic_locals, :static_locals, :dynamic_local_type_inferences, :dynamic_local_values
  alias inherit_dynamic_locals? inherit_dynamic_locals

  def fetch_type_inference(name, include_dynamic_locals: true)
    return dynamic_local_type_inferences[name] if include_dynamic_locals && dynamic_local_type_inferences.include?(name)
    return static_locals[name] if static_locals.include?(name)
    parent.fetch_type_inference(name, include_dynamic_locals: inherit_dynamic_locals && include_dynamic_locals)
  end

  def has_dynamic_binding?(name)
    return true if name.in? dynamic_local_type_inferences
    return parent.has_dynamic_binding?(name) if inherit_dynamic_locals
    false
  end

  def has_static_binding?(name)
    return true if name.in? static_locals
    return parent.has_static_binding?(name)
    false
  end
  
  def set_static_type_inference(name, type_inference)
    static_locals[name] = type_inference
  end

  def set_dynamic_type_inference(name, type_inference)
    dynamic_local_type_inferences[name] = type_inference
  end

  def set_dynamic_value(name, value)
    raise "attempting to set dynamic value for unbound name #{name}" unless name.in? dynamic_local_type_inferences
    raise "attempting to redefine dynamic value for #{name}" unless name.in? dynamic_local_type_inferences
    dynamic_local_values[name] = value
  end

  def fetch_dynamic_slot_index(name)
    dynamic_local_slots_by_super_binding_and_name.fetch([self, name])
  end

  def fetch_static_type_inference(name)
    static_locals.fetch(name) { parent.fetch_static_type_inference(name) }
  end

  def validate_name(name)
    raise "attempting to redefine #{name}" if name.in? static_locals
    current_super_binding = self
    while current_super_binding.inherit_dynamic_locals
      raise "attempting to redefine #{name}" if name.in? dynamic_local_type_inferences
      current_super_binding = current_super_binding.parent
    end
  end

  def spawn(inherit_dynamic_locals: false)
    SuperBinding.
      new(
        parent: self,
        inherit_dynamic_locals: inherit_dynamic_locals
    ).tap do |spawned|
      downstream_super_bindings << spawned
    end
  end

  def downstream_super_bindings
    @downstream_super_bindings ||= []
  end

  def dynamic_local_slots_by_super_binding_and_name
    @dynamic_local_slots_by_super_binding_and_name ||=
      if inherit_dynamic_locals
        super
      else
        next_slot_index = 0
        all_downstream_dynamic_locals.each_with_object({}) do |super_binding_and_name, acc|
          acc[super_binding_and_name] = next_slot_index
          next_slot_index += 1
        end
      end
  end

  def all_downstream_dynamic_locals
    dynamic_local_type_inferences.keys.map { |name| [self, name] } + downstream_super_bindings.flat_map(&:all_downstream_dynamic_locals)
  end

  def to_s
    flattened_bindings = {}

    current_super_binding_for_dynamics = self
    while current_super_binding_for_dynamics.present?
      current_super_binding_for_dynamics.dynamic_local_type_inferences.each do |local|
        next if local.name.in? flattened_bindings
        flattened_bindings[local.name] = local.value.complete? ? local.value.type.to_s : "?"
      end
      current_super_binding_for_dynamics =
        current_super_binding_for_dynamics.inherit_dynamic_locals? ? current_super_binding_for_dynamics.parent : nil
    end

    current_super_binding_for_statics = self
    while current_super_binding_for_statics.present?
      current_super_binding_for_statics.static_locals.each do |local|
        next if local.name.in? flattened_bindings
        flattened_bindings[local.name] = local.value.complete? ? local.value.type.to_s : "?"
      end
      current_super_binding_for_statics = current_super_binding_for_statics.parent
    end

    flattened_bindings.to_s
  end
end
