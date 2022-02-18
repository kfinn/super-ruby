module Types
  class ConcreteProcedure
    include BaseType

    class Instance
      def initialize(bytecode)
        @bytecode = bytecode
      end
      attr_reader :bytecode
      delegate :pointer, to: :bytecode, prefix: true
    end

    def initialize(argument_types, return_type)
      @argument_types = argument_types
      @return_type = return_type
    end
    attr_reader :argument_types, :return_type

    def ==(other)
      other.kind_of?(ConcreteProcedure) && state == other.state
    end
  
    delegate :hash, to: :state
  
    def state
      [argument_types, return_type]
    end

    def to_s
      "(ConcreteProcedure (#{argument_types.map(&:to_s).join(", ")}) #{return_type.to_s})"
    end

    def message_send_result_type_inference(message, argument_ast_nodes)
      case message
      when 'call'
        raise "Invalid arguments count: expected #{argument_types.size}, but got #{argument_ast_nodes.size}" unless argument_ast_nodes.size == argument_types.size
        Jobs::ConcreteProcedureCallTypeInference.new(self, Workspace.current_workspace.type_inferences_for(argument_ast_nodes))
      else
        super
      end
    end

    def build_message_send_bytecode!(type_inference)
      case type_inference.message
      when 'call'
        type_inference
        .argument_ast_nodes
        .zip(
          type_inference
            .result_type_inference
            .argument_type_inferences
        ).map do |argument_ast_node, argument_type_inference|
          argument_ast_node.build_bytecode!(argument_type_inference)
        end

        Workspace.current_workspace.current_bytecode_builder << Opcodes::CALL
        Workspace.current_workspace.current_bytecode_builder << argument_types.size
      else
        super
      end
    end

    def build_body_super_binding(procedure_specialization)
      procedure_specialization
        .argument_names
        .zip(argument_types)
        .each_with_object(
          procedure_specialization.super_binding.spawn
        ) do |(argument_name, argument_type), super_binding_builder|
          super_binding_builder.set_dynamic_type_inference(
            argument_name,
            Jobs::ImmediateTypeInference.new(argument_type)
          )
        end
    end

    def instance(procedure_specialization)
      buffer_builder = BufferBuilder.new
      procedure_specialization.workspace.with_current_super_binding(
        build_body_super_binding(procedure_specialization)
      ) do
        buffer_builder = BufferBuilder.new
        procedure_specialization.workspace.with_current_bytecode_builder(
          buffer_builder
        ) do
          procedure_specialization.body.build_bytecode!(procedure_specialization.body_type_inference)
          Workspace.current_workspace.current_bytecode_builder << Opcodes::RETURN
        end
      end
      Instance.new(buffer_builder)
    end
  end
end
