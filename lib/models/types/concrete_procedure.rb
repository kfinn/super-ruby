module Types
  class ConcreteProcedure
    def initialize(procedure_specialization)
      @procedure_specialization = procedure_specialization
    end
    attr_reader :procedure_specialization
    delegate :abstract_procedure, :argument_types_by_name, to: :procedure_specialization
    delegate :super_binding, :body, :argument_names, to: :abstract_procedure

    def ==(other)
      other.kind_of?(ConcreteProcedure) && state == other.state
    end
  
    delegate :hash, to: :state
  
    def state
      [argument_types_by_name, abstract_procedure]
    end

    def to_s
      "(#{argument_types_by_name.map(&:to_s).join(", ")}) -> #{return_type.to_s}"
    end

    def delivery_strategy_for_message(message)
      :dynamic
    end

    def message_send_result_typing(message, argument_typings)
      case message
      when 'call'
        raise "Invalid arguments count: expected #{argument_names.size}, but got #{argument_typings.size}" unless argument_typings.size == argument_names.size
        Jobs::ConcreteProcedureCallTyping.new(self, argument_names.zip(argument_typings).to_h)
      else
        raise "invalid message: #{message}"
      end
    end

    def bytecode_pointer
      workspace = Workspace.current_workspace
      unless workspace.in? bytecode_builders_by_workspace
        bytecode_builder = BufferBuilder.new
        workspace.with_current_bytecode_builder(bytecode_builder) do
          workspace.with_current_super_binding(body_super_binding) do
            body.build_bytecode!(workspace.typing_for(body))
            workspace.current_bytecode_builder << Opcodes::RETURN
          end
        end
        bytecode_builders_by_workspace[workspace] = bytecode_builder
      end
      bytecode_builders_by_workspace[workspace].pointer
    end

    def build_message_send_bytecode!(typing)
      argument_names.each do |argument_name|
        Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_workspace.current_bytecode_builder << body_super_binding.fetch_dynamic_slot_index(argument_name)
      end

      Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_workspace.current_bytecode_builder << argument_names.size
      
      Workspace.current_workspace.current_bytecode_builder << Opcodes::CALL
    end

    def body_super_binding
      @body_super_binding ||=
        argument_types_by_name
        .each_with_object(
          super_binding.spawn
        ) do |(argument_name, argument_type), super_binding_builder|
          super_binding_builder.set_dynamic_typing(
            argument_name,
            Jobs::ImmediateTyping.new(argument_type)
          )
        end
    end

    private

    def bytecode_builders_by_workspace
      @bytecode_builders_by_workspace ||= {}
    end
  end
end
