module Types
  class ConcreteProcedure
    class Instance
      def initialize(bytecode)
        @bytecode = bytecode
      end
      attr_reader :bytecode
      delegate :pointer, to: :bytecode, prefix: true
    end

    def initialize(argument_types_by_name, return_type)
      @argument_types_by_name = argument_types_by_name
      @return_type = return_type
    end
    attr_reader :argument_types_by_name, :return_type

    def argument_names
      argument_types_by_name.keys
    end

    def ==(other)
      other.kind_of?(ConcreteProcedure) && state == other.state
    end
  
    delegate :hash, to: :state
  
    def state
      [argument_types_by_name, return_type]
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

    def build_message_send_bytecode!(typing)
      body_super_binding = build_body_super_binding(typing.receiver_typing.super_binding)
      argument_names.each do |argument_name|
        Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_workspace.current_bytecode_builder << body_super_binding.fetch_dynamic_slot_index(argument_name)
      end

      Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_workspace.current_bytecode_builder << argument_names.size
      
      Workspace.current_workspace.current_bytecode_builder << Opcodes::CALL
    end

    def build_body_super_binding(definition_super_binding)
      argument_types_by_name
      .each_with_object(
        definition_super_binding.spawn
      ) do |(argument_name, argument_type), super_binding_builder|
        super_binding_builder.set_dynamic_typing(
          argument_name,
          Jobs::ImmediateTyping.new(argument_type)
        )
      end
    end

    def instance(procedure_specialization)
      buffer_builder = BufferBuilder.new
      procedure_specialization.workspace.with_current_super_binding(
        build_body_super_binding(procedure_specialization.super_binding)
      ) do
        buffer_builder = BufferBuilder.new
        procedure_specialization.workspace.with_current_bytecode_builder(
          buffer_builder
        ) do
          procedure_specialization.body.build_bytecode!(procedure_specialization.return_typing)
          Workspace.current_workspace.current_bytecode_builder << Opcodes::RETURN
        end
      end
      Instance.new(buffer_builder)
    end
  end
end
