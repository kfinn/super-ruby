class RootSuperBinding
  include Singleton

  def super_respond_to?(message)
    receiver_type_inference_for(message).present?
  end

  def receiver_type_inference_for!(message)
    receiver_type_inference_for(message).tap do |receiver_type_inference|
      raise "programmer error: no receiver type inference for #{message}" unless receiver_type_inference.present?
    end
  end

  def receiver_type_inference_for(message)
    case message
    when 'define'
      Jobs::ImmediateTypeInference.new(
        Types::SuperBinding.new(Workspace.current_super_binding)
      )
    end
  end

  def build_receiver_bytecode_for!(message)
    case message
    when 'define'
      Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_bytecode_builder << Types::Void.instance.instance
    end
  end

  def fetch_type_inference(name, **_kwargs)
    case name
    when 'Integer'
      Jobs::ImmediateEvaluation.new(Types::Type.instance, Types::Integer.instance)
    when 'Boolean'
      Jobs::ImmediateEvaluation.new(Types::Type.instance, Types::Boolean.instance)
    when 'Void'
      Jobs::ImmediateEvaluation.new(Types::Type.instance, Types::Void.instance)
    when 'Type'
      Jobs::ImmediateEvaluation.new(Types::Type.instance, Types::Type.instance)
    when /^(0|-?[1-9](\d)*)$/
      Jobs::ImmediateEvaluation.new(Types::Integer.instance, name.to_i)
    when 'true'
      Jobs::ImmediateEvaluation.new(Types::Boolean.instance, true)
    when 'false'
      Jobs::ImmediateEvaluation.new(Types::Boolean.instance, false)
    else
      raise "unknown identifier: #{name}"
    end
  end

  def has_dynamic_binding?(name)
    false
  end

  def has_static_binding?(name)
    fetch_type_inference(name).present?
  end
  
  alias fetch_static_type_inference fetch_type_inference

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

  def static_locals
    []
  end

  def parent
    nil
  end
end
