module SuperRuby
  module Builtins
    class Define < Base
      def self.match?(list)
        super && list.size == 4
      end

      def typecheck!(scope)
        Value::Type::VOID
      end

      def evaluate!(scope)
        identifier_ast_node = list.second
        identifier = identifier_ast_node.evaluate! scope

        type_ast_node = list.third
        value_ast_node = list.fourth

        value_type = value_ast_node.typecheck!(scope.spawn)
        if type_ast_node.present? && type_ast_node.evaluate!(scope.spawn) != value_type
          raise 'type mismatch'
        end

        scope.define! identifier, value_type, value_ast_node
        Values::Void.instance
      end
    end
  end
end
