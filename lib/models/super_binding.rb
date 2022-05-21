class SuperBinding
  def initialize(
    parent:,
    inherit_dynamic_locals: false,
    static_locals: LocalsCollection.new,
    dynamic_local_type_inferences: LocalsCollection.new,
    dynamic_local_values: LocalsCollection.new
  )
    @parent = parent
    @inherit_dynamic_locals = inherit_dynamic_locals
    @static_locals = static_locals
    @dynamic_local_type_inferences = dynamic_local_type_inferences
    @dynamic_local_values = dynamic_local_values
  end

  attr_reader :parent, :inherit_dynamic_locals, :static_locals, :dynamic_local_type_inferences, :dynamic_local_values
  alias inherit_dynamic_locals? inherit_dynamic_locals

  def super_respond_to?(message_send)
    receiver_type_inference_for(message_send).present?
  end

  def receiver_type_inference_for!(message_send)
    receiver_type_inference_for(message_send).tap do |receiver_type_inference|
      raise "programmer error: no receiver type inference for #{message_send}" unless receiver_type_inference.present?
    end
  end

  def receiver_type_inference_for(message_send)
    puts "searching for type_inference for #{message_send.message} within #{to_s}" if ENV['DEBUG']

    return nil if message_send.argument_s_expressions.any?
    responder = responder_chain.find do |responder|
      responder.super_respond_to? message_send
    end
    responder&.job
  end

  def responder_chain
    @responder_chain ||= dynamic_responder_chain + static_responder_chain
  end

  def dynamic_responder_chain
    @dynamic_responder_chain ||= (
      [Types::DynamicSuperBinding.new(self)] +
      (inherit_dynamic_locals? ? parent.dynamic_responder_chain : [])
    )
  end

  def static_responder_chain
    @static_responder_chain ||= ([Types::StaticSuperBinding.new(self)] + parent.static_responder_chain)
  end

  def build_receiver_bytecode_for!(message_send)
    message_send.receiver_type_inference.type.build_receiver_bytecode!(message_send)
  end

  def has_static_binding?(name)
    name.in? static_locals
  end
  
  def set_static_type_inference(name, type_inference)
    static_locals[name] = type_inference
  end

  def set_dynamic_type_inference(name, type_inference)
    dynamic_local_type_inferences[name] = type_inference
  end

  def fetch_dynamic_slot_index(name)
    dynamic_local_slots_by_super_binding_and_name.fetch([self, name])
  end

  def fetch_static_type_inference(name)
    static_locals[name]
  end

  def spawn(inherit_dynamic_locals: false)
    SuperBinding.
      new(
        parent: self,
        inherit_dynamic_locals: inherit_dynamic_locals
    ).tap do |spawned|
      downstream_super_bindings << spawned
    end
  end

  def downstream_super_bindings
    @downstream_super_bindings ||= []
  end

  def dynamic_local_slots_by_super_binding_and_name
    @dynamic_local_slots_by_super_binding_and_name ||=
      if inherit_dynamic_locals
        parent.dynamic_local_slots_by_super_binding_and_name
      else
        next_slot_index = 0
        all_downstream_dynamic_locals.each_with_object({}) do |super_binding_and_name, acc|
          acc[super_binding_and_name] = next_slot_index
          next_slot_index += 1
        end
      end
  end

  def all_downstream_dynamic_locals
    dynamic_local_type_inferences.keys.map { |name| [self, name] } + downstream_super_bindings.flat_map(&:all_downstream_dynamic_locals)
  end

  def inspect
    to_s
  end

  def to_s
    "<super binding>"
  end
end
