module SuperRuby
  class Scope
    class GlobalScope
      include Singleton

      GlobalScopeBuiltIn = Struct.new(:value) do
        def evaluate!(_scope)
          value
        end
      end

      BUILTINS = {
        'Void' => GlobalScopeBuiltIn.new(Values::Type::VOID),
        'Type' => GlobalScopeBuiltIn.new(Values::Type::TYPE),
        'Integer' => GlobalScopeBuiltIn.new(Values::Type::INTEGER),
        'Float' => GlobalScopeBuiltIn.new(Values::Type::FLOAT),
        'String' => GlobalScopeBuiltIn.new(Values::Type::STRING)
      }

      def resolve(identifier)
        BUILTINS[identifier]
      end
    end

    attr_accessor :parent

    def initialize(parent=GlobalScope.instance)
      @parent = parent
    end

    def spawn
      self.class.new(self)
    end

    def bound_receivers
      @bound_receivers ||= {}
    end

    def bound_types
      @bound_types ||= {}
    end

    def resolve(identifier)
      bound_receivers.fetch identifier do
        raise "unknown identifier: #{identifier}" unless parent.present?
        parent.resolve(identifier)
      end
    end

    def define_type!(identifier, type)
      bound_types[identifier] = type
    end

    def define!(identifier, type, value)
      raise "redefinition of existing identifier: #{identifier}" if bound_receivers.include? identifier

      bound_receivers[identifier] = value
    end
  end
end
