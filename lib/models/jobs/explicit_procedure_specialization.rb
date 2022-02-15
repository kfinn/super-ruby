module Jobs
  class ExplicitProcedureSpecialization
    prepend BaseJob

    def initialize(abstract_procedure, concrete_procedure_typing)
      @abstract_procedure = abstract_procedure
      @concrete_procedure_typing = concrete_procedure_typing
    end
    attr_reader :abstract_procedure, :concrete_procedure_typing
    attr_accessor :implicit_procedure_specialization, :validated
    delegate :argument_types, to: :concrete_procedure
    delegate :argument_names, :ast_node, :workspace, :super_binding, to: :abstract_procedure
    attr_accessor :validated
    alias complete? validated

    def concrete_procedure
      concrete_procedure_typing.value
    end
    alias type concrete_procedure

    attr_accessor :cached_procedure_specialization, :own_body_typing

    def body_typing
      cached_procedure_specialization&.own_body_typing || own_body_typing
    end

    delegate :concrete_procedure_instance, to: :implicit_procedure_specialization

    def work!
      return unless concrete_procedure_typing.complete?
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
      "(#{abstract_procedure.to_s} specialize #{concrete_procedure_typing.to_s})"
    end
  end
end
