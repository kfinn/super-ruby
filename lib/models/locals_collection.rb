class LocalsCollection
  Local = Struct.new(:name, :value)

  def initialize(
    locals: [],
    locals_index_by_name: {}
  )
    @locals = locals
    @locals_index_by_name = locals_index_by_name
  end

  attr_reader :locals, :locals_index_by_name

  def include?(name)
    name.in? locals_index_by_name
  end

  def [](name)
    locals[locals_index_by_name.fetch(name)].value
  end

  def []=(name, value)
    puts "setting #{name} to #{value}" if ENV["DEBUG"]
    raise "attempting to redefine #{name}" if name.in? locals
    local = Local.new(name, value)
    locals_index_by_name[name] = locals.size
    locals << local
  end

  def fetch(name)
    return yield unless include? name
    self[name]
  end

  def dup
    self.class.new(
      locals: locals.map(&:dup),
      locals_index_by_name: locals_index_by_name.dup
    )
  end

  include Enumerable
  delegate :each, to: :locals
  delegate :keys, to: :locals_index_by_name
end
