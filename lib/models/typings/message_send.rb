module Typings
  class MessageSend
    def initialize(receiver_typing, message_ast_node, argument_typings)
      @receiver_typing = receiver_typing
      @message_ast_node = message_ast_node
      @argument_typings = argument_typings
    end
    attr_reader :receiver_typing, :message_ast_node, :argument_typings

    def dependencies
      @dependencies ||= [receiver_typing, *argument_typings]
    end

    def complete?
      @complete ||= dependencies.all?(&:complete?)
    end

    def type
      raise 'attempted to derive an incomplete type' unless complete?
      @type ||= receiver_typing.type.message_send_result_type(message_ast_node.text, argument_typings)
    end
  end
end
