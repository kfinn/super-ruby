module Jobs
  class ProcedureSpecialization
    prepend BaseJob

    def initialize(abstract_procedure, concrete_procedure_typing)
      @abstract_procedure = abstract_procedure
      @concrete_procedure_typing = concrete_procedure_typing
    end
    attr_reader :abstract_procedure, :concrete_procedure_typing
    delegate :argument_names, :ast_node, :workspace, :super_binding, to: :abstract_procedure
    attr_accessor :validated
    alias complete? validated

    def concrete_procedure
      concrete_procedure_typing.value
    end
    alias type concrete_procedure

    def body
      @body ||= abstract_procedure.body.dup
    end

    attr_accessor :cached_procedure_specialization, :own_body_typing

    def body_typing
      cached_procedure_specialization&.own_body_typing || own_body_typing
    end

    def concrete_procedure_instance
      @concrete_procedure_instance ||= concrete_procedure.instance(self)
    end

    def work!
      return unless concrete_procedure_typing.complete?

      if body_typing.nil?
        self.cached_procedure_specialization = abstract_procedure.cached_procedure_specialization_for_concrete_procedure(concrete_procedure)
        if cached_procedure_specialization.present?
          cached_procedure_specialization.add_downstream(self)
        else
          abstract_procedure.define_procedure_specialization(self)
          own_body_typing_super_binding =
            argument_names.zip(concrete_procedure.argument_types).each_with_object(super_binding.spawn) do |(argument_name, argument_type), super_binding_builder|
              super_binding_builder.set_dynamic_typing(argument_name, Jobs::ImmediateTyping.new(argument_type))
            end
          self.own_body_typing = Workspace.current_workspace.with_current_super_binding(own_body_typing_super_binding) do
            Workspace.current_workspace.typing_for body
          end
          own_body_typing.add_downstream(self)
        end
      end

      return unless body_typing.complete?
      raise "Invalid specialization return type:\n\texpected #{body_typing.type.to_s}\n\tactual: #{concrete_procedure.return_type.to_s}" unless body_typing.type == concrete_procedure.return_type
      self.validated = true
    end

    def to_s
      "(#{abstract_procedure.to_s} specialize #{concrete_procedure_typing.to_s})"
    end
  end
end
