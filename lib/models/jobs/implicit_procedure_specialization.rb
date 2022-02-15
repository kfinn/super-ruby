module Jobs
  class ImplicitProcedureSpecialization
    prepend BaseJob

    def initialize(abstract_procedure, argument_typings)
      @abstract_procedure = abstract_procedure
      @argument_typings = argument_typings
    end
    attr_reader :abstract_procedure, :argument_typings
    delegate :argument_names, :ast_node, :workspace, :super_binding, to: :abstract_procedure
    attr_accessor :concrete_procedure
    alias type concrete_procedure

    def argument_types
      argument_typings.map(&:type)
    end

    def complete?
      concrete_procedure.present?
    end

    attr_accessor :cached_implicit_procedure_specialization, :own_body_typing

    def body_typing
      cached_implicit_procedure_specialization&.own_body_typing || own_body_typing
    end

    def concrete_procedure_instance
      @concrete_procedure_instance ||= concrete_procedure.instance(self)
    end

    def work!
      return unless argument_typings.all?(&:complete?)

      if body_typing.nil?
        self.cached_implicit_procedure_specialization = abstract_procedure.cached_implicit_procedure_specialization_for_argument_types(argument_types)
        if cached_implicit_procedure_specialization.nil?
          abstract_procedure.define_implicit_procedure_specialization(self)
          own_body_typing_super_binding =
            argument_names.zip(argument_types).each_with_object(super_binding.spawn) do |(argument_name, argument_type), super_binding_builder|
              super_binding_builder.set_dynamic_typing(argument_name, Jobs::ImmediateTypeInference.new(argument_type))
            end
          self.own_body_typing = Workspace.current_workspace.with_current_super_binding(own_body_typing_super_binding) do
            Workspace.current_workspace.typing_for body
          end
        end
        body_typing.add_downstream(self)
      end
      return unless body_typing.complete?
      self.concrete_procedure = Types::ConcreteProcedure.new(argument_types, body_typing.type)
    end

    def body
      @body ||= abstract_procedure.body.dup
    end

    def to_s
      "(#{abstract_procedure.to_s} implicitly_specialize (#{argument_typings.map { |argument_typing| " #{argument_typing.to_s}" }.join}))"
    end
  end
end
