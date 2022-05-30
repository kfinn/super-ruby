class DeferredTypeCheckSuperBinding
  def initialize(parent)
    @parent = parent
  end
  attr_reader :parent

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

    responder = responder_chain.find do |responder|
      responder.super_respond_to? message_send
    end
    responder&.job
  end
end
