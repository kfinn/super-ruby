class RootSuperBinding
  include Singleton

  def receiver_type_inference_for(message_send)
    case message_send.message
    when 'Integer', 'Boolean', 'Void', 'Type', 'true', 'false', /^(0|-?[1-9](\d)*)$/
      if message_send.argument_s_expressions.size == 0
        Jobs::ImmediateEvaluation.new(Types::RootSuperBinding.new(Workspace.current_super_binding, include_dynamic_locals: false), Workspace.current_super_binding)
      end
    end
  end

  def build_receiver_bytecode_for!(message_send)
    case message_send.message
    when 'Integer', 'Boolean', 'Void', 'Type', 'true', 'false', /^(0|-?[1-9](\d)*)$/
      Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_bytecode_builder << Types::SuperBinding.new(Workspace.current_super_binding, include_dynamic_locals: false)
    end
  end

  def static_responder_chain
    @static_responder_chain ||= [Types::RootSuperBinding.new(self)]
  end

  def spawn(inherit_dynamic_locals: false)
    raise "cannot spawn from root binding when inheriting dynamic locals" if inherit_dynamic_locals

    SuperBinding.
      new(
        parent: self,
        inherit_dynamic_locals: false
    )
  end

  def to_s
    "<root super binding>"
  end
end
