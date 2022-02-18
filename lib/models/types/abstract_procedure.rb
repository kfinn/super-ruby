module Types
  class AbstractProcedure
    include BaseType

    def initialize(argument_names, body)
      @argument_names = argument_names
      @body = body
      @workspace = Workspace.current_workspace
      @super_binding = @workspace.current_super_binding
    end
    attr_reader :argument_names, :body, :workspace, :super_binding

    def message_send_result_type_inference(message, argument_ast_nodes)
      case message
      when 'call'
        raise "invalid arguments count to AbstractProceudure#call. Expected #{argument_names.size}, got #{argument_ast_nodes.size}" unless argument_ast_nodes.size == argument_names.size
        Jobs::AbstractProcedureCallTypeInference.new(self, Workspace.current_workspace.type_inferences_for(argument_ast_nodes))
      when 'specialize'
        raise "invalid arguments count to AbstractProcedure#specialize. Expected 1, got #{argument_ast_nodes.size}" unless argument_ast_nodes.size == 1
        Jobs::ExplicitProcedureSpecializationTypeInference.new(self, Jobs::Evaluation.new(argument_ast_nodes.first))
      else
        super
      end
    end

    def build_message_send_bytecode!(type_inference)
      Workspace.current_workspace.current_bytecode_builder << Opcodes::DISCARD

      case type_inference.message
      when 'call'
        implicit_procedure_specialization = cached_implicit_procedure_specialization_for_argument_types(
          type_inference
            .result_type_inference
            .argument_type_inferences
            .map(&:type)
        )

        Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_workspace.current_bytecode_builder << implicit_procedure_specialization.concrete_procedure_instance.bytecode_pointer

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
        Workspace.current_workspace.current_bytecode_builder << type_inference.argument_ast_nodes.size
      when 'specialize'        
        concrete_procedure_instance =
          type_inference
          .result_type_inference
          .concrete_procedure_instance

        Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_workspace.current_bytecode_builder << concrete_procedure_instance.bytecode_pointer
      else
        super
      end
    end

    def cached_implicit_procedure_specialization_for_argument_types(argument_types)
      cached_implicit_procedure_specializations_by_argument_types[argument_types]
    end

    def declare_specialization(argument_types)
      return if argument_types.in? cached_implicit_procedure_specializations_by_argument_types
      define_implicit_procedure_specialization(
        Jobs::ImplicitProcedureSpecialization.new(
          self,
          argument_types.map do |argument_type|
            Jobs::ImmediateTypeInference.new(argument_type)
          end
        )
      )
    end

    def define_implicit_procedure_specialization(implicit_procedure_specialization)
      if implicit_procedure_specialization.argument_types.in? cached_implicit_procedure_specializations_by_argument_types
        raise "duplicate procedure specialization for #{self}: #{implicit_procedure_specialization.argument_types.to_s}" 
      end
      cached_implicit_procedure_specializations_by_argument_types[implicit_procedure_specialization.argument_types] = implicit_procedure_specialization
    end

    def to_s
      "(AbstractProcedure (#{argument_names.size.times.map { "?" }.join(", ")}) ?)"
    end

    private

    def cached_implicit_procedure_specializations_by_argument_types
      @cached_implicit_procedure_specializations_by_argument_types ||= {}
    end
  end
end
