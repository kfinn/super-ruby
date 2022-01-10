class SuperBinding
  def initialize(parent=nil)
    @parent = parent
  end

  attr_reader :parent

  def fetch(name)
    locals.fetch(name) do
      raise "unknown identifier: #{name}" unless parent.present?
      parent.fetch(name)
    end
  end

  def set(name, value)
    locals[name] = value
  end

  def locals
    @locals ||= {}
  end

  def spawn
    SuperBinding.new(self)
  end

  def to_s
    state.transform_values(&:to_s)
  end

  def ==(other)
    state == other.state
  end

  def hash
    state.hash
  end

  def state
    locals.each_with_object(parent&.state || {}) do |(name, value), acc|
      acc[name] = value
    end
  end
end
