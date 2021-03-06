module Jobs
  class ImplicitProcedureSpecialization
    prepend BaseJob

    def initialize(abstract_procedure, argument_type_inferences)
      @abstract_procedure = abstract_procedure
      @argument_type_inferences = argument_type_inferences
    end
    attr_reader :abstract_procedure, :argument_type_inferences
    delegate :argument_names, :ast_node, :workspace, :super_binding, to: :abstract_procedure
    attr_accessor :concrete_procedure
    alias type concrete_procedure

    def argument_types
      argument_type_inferences.map(&:type)
    end

    def complete?
      concrete_procedure.present?
    end

    attr_accessor :cached_implicit_procedure_specialization, :own_body_type_inference, :body

    def body_type_inference
      cached_implicit_procedure_specialization&.own_body_type_inference || own_body_type_inference
    end

    def concrete_procedure_instance
      @concrete_procedure_instance ||= concrete_procedure.instance(self)
    end

    def work!
      return unless argument_type_inferences.all?(&:complete?)

      if body_type_inference.nil?
        self.cached_implicit_procedure_specialization = abstract_procedure.implicit_procedure_specialization_for_argument_types(argument_types)
        
        if cached_implicit_procedure_specialization == self || cached_implicit_procedure_specialization.nil?
          if cached_implicit_procedure_specialization.nil?
            abstract_procedure.define_implicit_procedure_specialization(self)
          end

          own_body_type_inference_super_binding =
            argument_names.zip(argument_types).each_with_object(super_binding.spawn) do |(argument_name, argument_type), super_binding_builder|
              super_binding_builder.set_dynamic_type_inference(argument_name, Jobs::ImmediateTypeInference.new(argument_type))
            end
          self.own_body_type_inference = Workspace.with_current_super_binding(own_body_type_inference_super_binding) do
            Workspace.type_inference_for(AstNode.from_s_expression(abstract_procedure.body_s_expression))
          end
          own_body_type_inference.add_downstream(self)
        else
          cached_implicit_procedure_specialization.add_downstream(self)
        end
      end
      return unless body_type_inference.complete?

      self.concrete_procedure = Types::ConcreteProcedure.new(argument_types, body_type_inference.type)
      self.body = body_type_inference.ast_node
    end

    def type_check
      @type_check ||= body_type_inference.type_check
    end

    def to_s
      "(#{abstract_procedure.to_s} implicitly_specialize (#{argument_type_inferences.map { |argument_type_inference| " #{argument_type_inference.to_s}" }.join}))"
    end
  end
end
