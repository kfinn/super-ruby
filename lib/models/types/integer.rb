module Types
  class Integer
    include Singleton

    def message_send_result_typing(message, argument_typings)
      case message
      when '+'
        raise "Invalid arguments count: expected 1, but got #{argument_typings.size}" unless argument_typings.size == 1
        IntegerPlusTyping.new(*argument_typings).tap do |integer_plus_typing|
          argument_typings.each { |argument_typing| argument_typing.add_downstream(integer_plus_typing) }
        end
      else
        raise "invalid message: #{message}"
      end
    end

    def immediate_integer_typing
      Jobs::ImmediateTyping.new(self)
    end

    class IntegerPlusTyping
      prepend Jobs::BaseJob

      def initialize(argument_typing)
        @argument_typing = argument_typing
      end
      attr_reader :argument_typing
      delegate :complete?, to: :argument_typing

      def complete?
        worked? && argument_typing.complete?
      end

      def work!
        return unless argument_typing.complete?
        raise "invalid argument to +: expected Integer, got #{argument_typing.type}" unless argument_typing.type == Integer.instance
        @worked = true
      end

      def worked?
        @worked
      end

      def type
        Integer.instance
      end
    end
  end
end
