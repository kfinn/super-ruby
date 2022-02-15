module Types
  module BaseType
    include ActiveSupport::Concern

    def delivery_strategy_for_message(message)
      :dynamic
    end

    def message_send_result_typing(message, argument_typings)
      case message
      when 'type'
        raise "invalid arguments count to #{self.class.name}#type. Expected 0, got #{argument_typings}.size" unless argument_typings.empty?
        Jobs::ImmediateEvaluation.new(Type.instance, self)
      else
        raise "invalid message: #{self.class.name}##{message}"
      end
    end
    
    def build_message_send_bytecode!(typing)
      case typing.message
      when 'type'
        Workspace.current_workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_workspace.current_bytecode_builder << self
      else
        raise "invalid message: #{self.class.name}##{message}"
      end
    end

    def to_s
      self.class.name.split("::").last
    end
  end
end
