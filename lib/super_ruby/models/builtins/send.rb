module SuperRuby
  module Builtins
    class Send < Base
      def self.match?(list)
        super && list.size >= 2
      end

      def initialize(list)
        @list = list
      end

      def typecheck!(scope)
        destination =
          if list.size == 2
            scope
          else
            children.second.evaluate! scope.spawn
          end

        message_ast_node =
          if list.size == 2
            children.second
          else
            children.third
          end
      end

      def evaluate!(scope)
        destination =
          if list.size == 2
            scope
          else
            children.second.evaluate! scope.spawn
          end

        message_ast_node =
          if list.size == 2
            children.second
          else
            children.third
          end
        
        identifier = message_ast_node.evaluate! scope.spawn

        result_expression = destination.resolve(identifier)
        result_expression.evaluate! scope.spawn
      end
    end
  end
end
