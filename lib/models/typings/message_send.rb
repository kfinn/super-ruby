module Typings
  class MessageSend
    prepend WorkQueue::Job

    def self.handle_ast_node(ast_node)
      return unless (
        ast_node.list? &&
        ast_node.size >= 2 &&
        ast_node.second.atom?
      )

      workspace = Workspace.current_workspace
      receiver_typing = workspace.typing_for(ast_node.first)
      argument_typings = ast_node[2..].map { |argument_ast_node| workspace.typing_for(argument_ast_node) }

      message_send_typing = Typings::MessageSend.new(
        receiver_typing,
        ast_node.second.text,
        argument_typings
      )
      
      receiver_typing.add_downstream(message_send_typing)
      argument_typings.each { |argument_typing| receiver_typing.add_downstream(argument_typing) }

      message_send_typing
    end

    def initialize(receiver_typing, message, argument_typings)
      @receiver_typing = receiver_typing
      @message = message
      @argument_typings = argument_typings
    end
    attr_reader :receiver_typing, :message, :argument_typings
    attr_accessor :result_typing

    def argument_typings_complete?
      @argument_typings_complete ||= receiver_typing.complete? && argument_typings.all?(&:complete?)
    end

    def result_typing_complete?
      result_typing&.complete?
    end

    def complete?
      argument_typings_complete? && result_typing_complete?
    end

    def work!
      if argument_typings_complete? && result_typing.blank?
        self.result_typing = 
          receiver_typing
          .type
          .message_send_result_typing(
            message,
            argument_typings.map(&:type)
          )
        self.result_typing.add_downstream(self)
      end
    end

    def type
      @type ||= result_typing.type
    end
  end
end
