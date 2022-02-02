module Types
  class ConcreteProcedure
    def initialize(argument_types_by_name, return_type, procedure_specialization)
      @argument_types_by_name = argument_types_by_name
      @return_type = return_type
      @procedure_specialization = procedure_specialization
    end

    attr_reader :argument_types_by_name, :return_type, :procedure_specialization
    delegate :abstract_procedure, :return_typing, :body_super_binding, to: :procedure_specialization
    delegate :body, :argument_names, to: :abstract_procedure

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

    def bytecode_pointer
      workspace = Workspace.current_workspace
      unless workspace.in? bytecode_pointers_by_workspace
        bytecode_builder = BufferBuilder.new
        workspace.with_current_bytecode_builder(bytecode_builder) do
          workspace.with_current_super_binding(body_super_binding) do
            body.build_bytecode!(return_typing)
            workspace.current_bytecode_builder << Opcodes::RETURN
          end
        end
        bytecode_pointers_by_workspace[workspace] = bytecode_builder.pointer
      end
      bytecode_pointers_by_workspace[workspace]
    end

    private

    def bytecode_pointers_by_workspace
      @bytecode_pointers_by_workspace ||= {}
    end
  end
end
