module Types
  module BaseType
    include ActiveSupport::Concern

    def decorate_message_send_receiver_type_inference(message_send_type_inference)
      message_send_type_inference.receiver_type_inference
    end

    def message_send_argument_type_inferences(message_send_type_inference)
      Workspace.type_inferences_for message_send_type_inference.argument_ast_nodes
    end

    def message_send_result_type_inference(message_send_type_inference)
      if message_send_type_inference.message.in? abstract_methods_by_name
        abstract_method = abstract_methods_by_name[message_send_type_inference.message]

        raise "invalid arguments count to #{message_send_type_inference.message}. Expected #{abstract_method.argument_names.size - 1}, got #{message_send_type_inference.argument_s_expressions.size}" unless message_send_type_inference.argument_s_expressions.size == abstract_method.argument_names.size - 1

        return Jobs::AbstractMethodCallTypeInference.new(
          abstract_method,
          [Jobs::ImmediateTypeInference.new(self)] + Workspace.type_inferences_for(message_send_type_inference.argument_s_expressions.map(&:ast_node))
        )
      end

      case message_send_type_inference.message
      when 'type'
        raise "invalid arguments count to #{self.class.name}#type. Expected 0, got #{message_send_type_inference.argument_s_expressions}.size" unless message_send_type_inference.argument_s_expressions.empty?
        Jobs::ImmediateEvaluation.new(Type.instance, self)
      else
        raise "invalid message: #{self.class.name}##{message_send_type_inference.message}"
      end
    end
    
    def build_message_send_bytecode!(type_inference)
      if type_inference.message.in? abstract_methods_by_name
        abstract_method = abstract_methods_by_name[type_inference.message]
        implicit_procedure_specialization = abstract_method.implicit_procedure_specialization_for_argument_types(
            type_inference
              .result_type_inference
              .argument_type_inferences
              .map(&:type)
        )

        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << implicit_procedure_specialization.concrete_procedure_instance.bytecode_pointer


        type_inference
          .argument_s_expressions
          .map(&:ast_node)
          .zip(
            type_inference
              .result_type_inference
              .argument_type_inferences
          ).map do |argument_ast_node, argument_type_inference|
            argument_ast_node.build_bytecode!(argument_type_inference)
          end
  
        Workspace.current_bytecode_builder << Opcodes::CALL_METHOD
        Workspace.current_bytecode_builder << type_inference.argument_s_expressions.size
        return
      end

      case type_inference.message
      when 'type'
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << self
      else
        raise "invalid message: #{self.class.name}##{type_inference.message}"
      end
    end

    def to_s
      self.class.name.split("::").last
    end

    def add_method_definition(name, argument_names, body)
      abstract_methods_by_name[name] = AbstractProcedure.new(
        ['self'] + argument_names,
        body
      )
    end

    def abstract_methods_by_name
      @abstract_methods_by_name ||= {}
    end
  end
end
