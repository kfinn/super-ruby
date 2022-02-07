module Jobs
  class ProcedureSpecialization
    prepend BaseJob

    def initialize(abstract_procedure, argument_typings_by_name)
      @abstract_procedure = abstract_procedure
      @argument_typings_by_name = argument_typings_by_name
    end
    attr_reader :abstract_procedure, :argument_typings_by_name
    delegate :ast_node, :body, :workspace, :super_binding, to: :abstract_procedure
    attr_accessor :concrete_procedure, :return_typings
    alias type concrete_procedure

    def concrete_procedure_instance
      @concrete_procedure_instance ||= concrete_procedure.instance(self)
    end

    def complete?
      concrete_procedure.present?
    end

    def return_typing
      cached_procedure_specialization&.return_typing || own_return_typing
    end

    def body
      @body ||= abstract_procedure.body.dup
    end

    attr_accessor :cached_procedure_specialization, :own_return_typing

    def work!
      return unless argument_typings_complete?

      if cached_procedure_specialization.nil? && own_return_typing.nil?
        self.cached_procedure_specialization = abstract_procedure.cached_procedure_specialization_for_argument_types(argument_types_by_name)
        if cached_procedure_specialization.present?
          self.cached_procedure_specialization.add_downstream(self)
        else
          self.own_return_typing = 
            workspace.with_current_super_binding(
              argument_typings_by_name
                .each_with_object(super_binding.spawn) do |(argument_name, argument_typing), super_binding_builder|
                  super_binding_builder.set_dynamic_typing(argument_name, Jobs::ImmediateTyping.new(argument_typing.value))
                end
            ) do
              workspace.typing_for(body)
            end
          self.own_return_typing.add_downstream(self)
          abstract_procedure.define_procedure_specialization(self)
          return
        end
      end

      return unless return_typing.complete?
      self.concrete_procedure = Types::ConcreteProcedure.new(
        argument_types_by_name,
        return_typing.type
      )
    end

    def argument_typings
      argument_typings_by_name.values
    end

    def argument_types_by_name
      @argument_types_by_name ||= argument_typings_by_name.transform_values(&:value)
    end

    def argument_typings_complete?
      argument_typings.all?(&:complete?)
    end

    def return_typing_complete?
      return_typing&.complete?
    end

    def return_type
      return_typing.type
    end
  end
end
