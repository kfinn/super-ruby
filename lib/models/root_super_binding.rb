class RootSuperBinding
  include Singleton

  def fetch_typing(name, **_kwargs)
    case name
    when 'Integer'
      Jobs::ImmediateTypedEvaluation.new(Types::Type.instance, Types::Integer.instance)
    when 'Boolean'
      Jobs::ImmediateTypedEvaluation.new(Types::Type.instance, Types::Boolean.instance)
    when 'Void'
      Jobs::ImmediateTypedEvaluation.new(Types::Type.instance, Types::Void.instance)
    when 'Type'
      Jobs::ImmediateTypedEvaluation.new(Types::Type.instance, Types::Type.instance)
    when /^(0|-?[1-9](\d)*)$/
      Jobs::ImmediateTypedEvaluation.new(Types::Integer.instance, name.to_i)
    when 'true'
      Jobs::ImmediateTypedEvaluation.new(Types::Boolean.instance, true)
    when 'false'
      Jobs::ImmediateTypedEvaluation.new(Types::Boolean.instance, false)
    else
      raise "unknown identifier: #{name}"
    end
  end

  def fetch_value(name, **_kwagrgs)
    fetch_typing(name).value
  end

  def has_dynamic_binding?(name)
    false
  end

  def has_static_binding?(name)
    fetch_typing(name).present?
  end
  
  alias fetch_static_typing fetch_typing

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
