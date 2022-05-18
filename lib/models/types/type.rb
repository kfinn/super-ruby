module Types
  class Type
    include Singleton
    include BaseType

    def decorate_message_send_receiver_type_inference(message_send_type_inference)
      case message_send_type_inference.message
      when 'define_method'
        Jobs::Evaluation.new(message_send_type_inference.receiver_type_inference.ast_node)
      else
        super
      end
    end

    def message_send_result_type_inference(type_inference)
      case type_inference.message
      when 'define_method'
        raise "Invalid arguments count: expected (name, arguments, body), but got #{type_inference.argument_s_expressions.join(' ')}" unless type_inference.argument_s_expressions.size == 3
        raise "Invalid name: expected identifier, but got #{type_inference.argument_s_expressions.first}" unless type_inference.argument_s_expressions.first.atom?
        raise "Invalid arguments: expected arguments list, but got #{type_inference.argument_s_expressions.second}" unless AstNodes::ArgumentListDefinition.match?(type_inference.argument_s_expressions.second)

        type_inference.receiver_type_inference.value.add_method_definition(
          type_inference.argument_s_expressions.first.text,
          AstNodes::ArgumentListDefinition.new(type_inference.argument_s_expressions.second).map(&:name),
          type_inference.argument_s_expressions.third.ast_node
        )

        Jobs::ImmediateTypeInference.new(Types::Void.instance)
      else
        super
      end
    end

    def build_message_send_bytecode!(type_inference)
      case type_inference.message
      when 'define_method'
        Workspace.current_bytecode_builder << Opcodes::DISCARD
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << Void.instance.instance
      else
        super
      end
    end
  end
end
