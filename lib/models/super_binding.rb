class SuperBinding
  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def fetch(name)
    locals.fetch(name) { parent&.fetch(name) }
  end

  def set(name, value)
    locals[name] = value
  end

  def locals
    @locals ||= {}
  end
end
