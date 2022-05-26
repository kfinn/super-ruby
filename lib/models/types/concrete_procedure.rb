module Types
  class ConcreteProcedure
    include BaseType
    include DerivesEquality

    class Instance
      def initialize(type, procedure_specialization)
        @type = type
        @procedure_specialization = procedure_specialization
      end
      attr_reader :type, :procedure_specialization
      attr_accessor :started_bytecode_generation
      alias started_bytecode_generation? started_bytecode_generation
      attr_accessor :started_llvm_function_generation
      alias started_llvm_function_generation? started_llvm_function_generation
      delegate :build_body_super_binding, to: :type
      delegate :pointer, to: :bytecode, prefix: true

      def bytecode
        @bytecode ||= BufferBuilder.new
        unless started_bytecode_generation?
          self.started_bytecode_generation = true

          in_procedure_specialization_context do
            Workspace.with_current_bytecode_builder(@bytecode) do
              procedure_specialization.body.build_bytecode!(procedure_specialization.body_type_inference)
              Workspace.current_bytecode_builder << Opcodes::RETURN
            end
          end
        end
        @bytecode
      end

      def llvm_function
        @llvm_function ||= Workspace.current_compilation.create_function!(type)
        unless started_llvm_function_generation?
          self.started_llvm_function_generation = true

          in_procedure_specialization_context do
            Workspace.with_current_basic_block(@llvm_function.entry_basic_block) do
              return_llvm_value = procedure_specialization.body.build_llvm!(procedure_specialization.body_type_inference)
              Workspace.current_basic_block << "ret #{type.return_type.build_llvm!} #{return_llvm_value}"
            end
          end
        end
        @llvm_function
      end

      def in_procedure_specialization_context
        procedure_specialization.workspace.as_current_workspace do
          Workspace.with_current_super_binding(
            build_body_super_binding(procedure_specialization)
          ) do
            yield
          end
        end
      end
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
      Instance.new(self, procedure_specialization).tap do |instance|
        instances_by_procedure_specialization[procedure_specialization] = instance
      end
    end

    private

    def instances_by_procedure_specialization
      @instances_by_procedure_specialization ||= {}
    end
  end
end
