class RootSuperBinding
  include Singleton

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
