module Jobs
  class ExplicitProcedureSpecialization
    prepend BaseJob

    def initialize(abstract_procedure, concrete_procedure_type_inference)
      @abstract_procedure = abstract_procedure
      @concrete_procedure_type_inference = concrete_procedure_type_inference
    end
    attr_reader :abstract_procedure, :concrete_procedure_type_inference
    attr_accessor :implicit_procedure_specialization, :validated
    delegate :argument_types, to: :concrete_procedure
    delegate :argument_names, :ast_node, :workspace, :super_binding, to: :abstract_procedure
    attr_accessor :validated
    alias complete? validated

    def concrete_procedure
      concrete_procedure_type_inference.value
    end
    alias type concrete_procedure

    attr_accessor :cached_procedure_specialization, :own_body_type_inference

    def body_type_inference
      cached_procedure_specialization&.own_body_type_inference || own_body_type_inference
    end

    delegate :concrete_procedure_instance, to: :implicit_procedure_specialization

    def work!
      return unless concrete_procedure_type_inference.complete?
      if implicit_procedure_specialization.nil?
        self.implicit_procedure_specialization = abstract_procedure.cached_implicit_procedure_specialization_for_argument_types(argument_types)
        if implicit_procedure_specialization.nil?
          self.implicit_procedure_specialization = Jobs::ImplicitProcedureSpecialization.new(
            abstract_procedure,
            argument_types.map { |argument_type| Jobs::ImmediateTypeInference.new(argument_type) }
          )
        end
        implicit_procedure_specialization.add_downstream(self)
      end
      return unless implicit_procedure_specialization.complete?
      
      raise "Invalid specialization type:\n\texpected #{implicit_procedure_specialization.type.to_s}\n\tactual: #{concrete_procedure.to_s}" unless implicit_procedure_specialization.type == concrete_procedure
      self.validated = true
    end

    def to_s
      "(#{abstract_procedure.to_s} specialize #{concrete_procedure_type_inference.to_s})"
    end
  end
end
