module Types
  class ConcreteProcedure
    def initialize(argument_types_by_name, return_type, procedure_specialization)
      @argument_types_by_name = argument_types_by_name
      @return_type = return_type
      @procedure_specialization = procedure_specialization
    end

    attr_reader :argument_types_by_name, :return_type, :procedure_specialization
    delegate :abstract_procedure, :return_typing, to: :procedure_specialization
    delegate :body, to: :abstract_procedure

    def ==(other)
      other.kind_of?(ConcreteProcedure) && state == other.state
    end
  
    delegate :hash, to: :state
  
    def state
      [argument_types_by_name, return_type, abstract_procedure]
    end

    def to_s
      "(#{argument_types_by_name.map(&:to_s).join(", ")}) -> #{return_type.to_s}"
    end

    def call(argument_values_by_name)
      Workspace
        .current_workspace
        .with_current_super_binding(
          procedure_specialization
            .body_super_binding
            .dup
            .tap do |draft_call_super_binding|
              argument_values_by_name.each do |name, value|
                draft_call_super_binding.set_dynamic_value(name, value)
              end
            end
        ) do
          body.evaluate(return_typing)
        end
    end
  end
end
