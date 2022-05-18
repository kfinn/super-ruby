module Types
  class ConcreteProcedure
    include BaseType
    include DerivesEquality

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

    def state
      [argument_types, return_type]
    end

    def to_s
      "(ConcreteProcedure (#{argument_types.map(&:to_s).join(", ")}) #{return_type.to_s})"
    end

    def message_send_result_type_inference(type_inference)
      case type_inference.message
      when 'call'
        raise "Invalid arguments count: expected #{argument_types.size}, but got #{type_inference.argument_s_expressions.size}" unless type_inference.argument_s_expressions.size == argument_types.size
        Jobs::ConcreteProcedureCallTypeInference.new(self, Workspace.type_inferences_for(type_inference.argument_s_expressions.map(&:ast_node)))
      else
        super
      end
    end

    def build_message_send_bytecode!(type_inference)
      case type_inference.message
      when 'call'
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

        Workspace.current_bytecode_builder << Opcodes::CALL_PROCEDURE
        Workspace.current_bytecode_builder << argument_types.size
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
      puts "instancing #{to_s} for #{procedure_specialization.to_s}" if ENV["DEBUG"]
      return instances_by_procedure_specialization[procedure_specialization] if instances_by_procedure_specialization.include? procedure_specialization

      buffer_builder = BufferBuilder.new
      result = Instance.new(buffer_builder)
      instances_by_procedure_specialization[procedure_specialization] = result
      procedure_specialization.workspace.with_current_super_binding(
        build_body_super_binding(procedure_specialization)
      ) do
        procedure_specialization.workspace.with_current_bytecode_builder(
          buffer_builder
        ) do
          procedure_specialization.body.build_bytecode!(procedure_specialization.body_type_inference)
          Workspace.current_bytecode_builder << Opcodes::RETURN
        end
      end

      result
    end

    private

    def instances_by_procedure_specialization
      @instances_by_procedure_specialization ||= {}
    end
  end
end
