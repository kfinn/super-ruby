module Typings
  class MessageSend
    def self.handle_ast_node(ast_node)
      return unless (
        ast_node.kind_of?(AstNodes::List)
        && ast_node.size >= 2
        && ast_node.second.kind_of(AstNodes::Atom)
      )

      typings_by_ast_node = Typing.current_typings_by_ast_node
      Typings::MessageSend.new(
        typings_by_ast_node[ast_node_list.first],
        ast_node_list.second.text,
        ast_node_list[2..].map { |argument_ast_node| typings_by_ast_node[argument_ast_node] }
      )
    end

    def initialize(receiver_typing, message, argument_typings)
      @receiver_typing = receiver_typing
      @message = message
      @argument_typings = argument_typings
    end
    attr_reader :receiver_typing, :message, :argument_typings

    def complete?
      return false unless receiver_typing.complete? && argument_typings.all?(&:complete?)
      typing_for_application.complete?      
    end

    def typing_for_application
      unless instance_variable_defined?(:@typing_for_application)
        raise unless receiver_typing.complete? && argument_typings.all(&:complete?)
        @typing_for_application = 
          receiver_typing
          .type
          .typing_for_message_send(
            message,
            argument_typings
          )
      end
      @typing_for_application
    end

    def type
      raise 'attempted to derive an incomplete type' unless complete?
      @type ||= typing_for_application.type
    end
  end
end
