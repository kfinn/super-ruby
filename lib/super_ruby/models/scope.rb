module SuperRuby
  class Scope
    class GlobalScope
      include Singleton

      GlobalScopeBuiltIn = Struct.new(:value) do
        def evaluate!(_scope, _memory)
          value
        end
      end

      BUILTINS = {
        **Values::Type.builtins,
        **Values::Procedure.builtins
      }.freeze

      def resolve(identifier)
        BUILTINS[identifier]
      end

      def spawn
        Scope.new(self)
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

    def resolve(identifier)
      bound_receivers.fetch(identifier) do |missing_identifier|
        if parent.present?
          parent.resolve(missing_identifier)
        else
          raise "unknown identifier: #{missing_identifier}"
        end
      end
    end

    def define!(identifier, value)
      raise "redefinition of existing identifier: #{identifier}" if bound_receivers.include? identifier

      bound_receivers[identifier] = value
    end

    def to_s
      receiver_strings = bound_receivers.map do |identifier, value|
        "(#{identifier} #{value})"
      end
      parent_string =
        if parent.present?
          "**#{parent}"
        end
      "(#{[*receiver_strings, parent_string].compact.join(" ")})"
    end
  end
end
