module Jobs
  class MessageSendTyping
    prepend BaseJob

    def initialize(receiver_typing, message, argument_ast_nodes)
      @receiver_typing = receiver_typing
      @message = message
      @argument_ast_nodes = argument_ast_nodes

      @receiver_typing.add_downstream(self)
    end
    attr_reader :receiver_typing, :message, :argument_ast_nodes
    attr_accessor :result_typing, :argument_typings
    delegate :type, to: :result_typing, allow_nil: true

    def upstream_typings_complete?
      @upstream_typings_complete ||= receiver_typing.complete? && !argument_typings.nil? && argument_typings.all?(&:complete?)
    end

    def result_typing_complete?
      result_typing&.complete?
    end

    def complete?
      upstream_typings_complete? && result_typing_complete?
    end

    def work!
      if receiver_typing.complete? && argument_typings.nil?
        case receiver_typing.type.delivery_strategy_for_message(message)
        when :static
          self.argument_typings = argument_ast_nodes.map do |argument_ast_node|
            TypedEvaluation.new(argument_ast_node)
          end
        when :dynamic
          self.argument_typings = argument_ast_nodes.map do |argument_ast_node|
            Workspace.current_workspace.typing_for argument_ast_node
          end
        end
        argument_typings.each do |argument_typing|
          argument_typing.add_downstream self
        end
      end

      if !argument_typings.nil? && argument_typings.all?(&:complete?)
        self.result_typing =
          receiver_typing
          .type
          .message_send_result_typing(
            message,
            argument_typings
          )
        result_typing.add_downstream(self)
      end
    end

    def to_s
      "(#{receiver_typing.to_s} #{message}#{argument_ast_nodes.map { |ast_node| " #{ast_node.s_expression.to_s}" }.join})"
    end
  end
end
