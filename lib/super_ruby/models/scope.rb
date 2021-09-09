module SuperRuby
  class Scope
    attr_accessor :parent

    def initialize(parent=nil)
      @parent = parent
    end

    def spawn
      self.class.new(self)
    end

    def bound_receivers
      @bound_receivers ||= {}
    end

    def resolve(identifier)
      bound_receivers.fetch identifier do
        raise "unknown identifier: #{identifier}" unless parent.present?
        parent.resolve(identifier)
      end
    end

    def define!(identifier, value)
      raise "redefinition of existing identifier: #{identifier}" if bound_receivers.include? identifier

      bound_receivers[identifier] = value
    end
  end
end
