module Types
  module BaseType
    include ActiveSupport::Concern

    def message_send_result_type_inference(message, argument_ast_nodes)
      case message
      when 'type'
        raise "invalid arguments count to #{self.class.name}#type. Expected 0, got #{argument_ast_nodes}.size" unless argument_ast_nodes.empty?
        Jobs::ImmediateEvaluation.new(Type.instance, self)
      else
        raise "invalid message: #{self.class.name}##{message}"
      end
    end
    
    def build_message_send_bytecode!(type_inference)
      case type_inference.message
      when 'type'
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << self
      else
        raise "invalid message: #{self.class.name}##{message}"
      end
    end

    def to_s
      self.class.name.split("::").last
    end
  end
end
