module SuperRuby
  class Scope
    class << self
      def current_scope
        raise unless @current_scope.present?
        @current_scope
      end

      def with_current_scope(current_scope)
        previous_current_scope = @current_scope
        @current_scope = current_scope
        yield
      ensure
        @current_scope = previous_current_scope
      end
    end

    attr_accessor :parent

    class EmptyScope
      include Singleton

      def resolve(identifier)
        raise "unknown identifier: #{identifier}"
      end
    end

    def self.empty
      EmptyScope.instance
    end

    def initialize(parent=Builtins)
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

    def extract_argument_values_for_procedure_call(procedure, list, caller_scope, memory)
      argument_value_expressions = list[1..-1]
      raise 'invalid arguments' unless argument_value_expressions.size == procedure.arguments.size

      argument_values = argument_value_expressions.map do |argument_value_expression|
        argument_value_expression.evaluate! caller_scope.spawn, memory
      end

      procedure.arguments
        .zip(argument_values)
        .each_with_object(procedure.scope.spawn) do |(argument, argument_value), draft_scope|
          draft_scope.define! argument, argument_value
        end
    end

    def extract_argument_values_for_method_call(method, list, caller_scope, memory)
      argument_value_expressions = list[2..-1]
      raise 'invalid arguments' unless argument_value_expressions.size == method.arguments.size

      argument_values = argument_value_expressions.map do |argument_value_expression|
        argument_value_expression.evaluate! caller_scope.spawn, memory
      end

      method.arguments
        .zip(argument_values)
        .each_with_object(method.scope.spawn) do |(argument, argument_value), draft_scope|
          draft_scope.define! argument, argument_value
        end
    end
  end
end

