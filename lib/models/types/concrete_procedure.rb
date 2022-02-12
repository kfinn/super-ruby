module Types
  class ConcreteProcedure
    include BaseType

    class Instance
      def initialize(bytecode)
        @bytecode = bytecode
      end
      attr_reader :bytecode
      delegate :pointer, to: :bytecode, prefix: true
    end

    def initialize(argument_types, return_type)
      @argument_types = argument_types
      @return_type = return_type
    end
    attr_reader :argument_types, :return_type

    def ==(other)
      other.kind_of?(ConcreteProcedure) && state == other.state
    end
  
    delegate :hash, to: :state
  
    def state
      [argument_types, return_type]
    end

    def to_s
      "(ConcreteProcedure (#{argument_types.map(&:to_s).join(", ")}) #{return_type.to_s})"
    end

    def message_send_result_typing(message, message_send_argument_typings)
      case message
      when 'call'
        raise "Invalid arguments count: expected #{argument_types.size}, but got #{message_send_argument_typings.size}" unless message_send_argument_typings.size == argument_types.size
        Jobs::ConcreteProcedureCallTyping.new(self, message_send_argument_typings)
      else
        super
      end
    end

    def build_message_send_bytecode!(typing)
      case typing.message
      when 'call'
        Workspace.current_workspace.current_bytecode_builder << Opcodes::CALL
        Workspace.current_workspace.current_bytecode_builder << argument_types.size
      else
        super
      end
    end

    def build_body_super_binding(procedure_specialization)
      procedure_specialization
        .argument_names
        .zip(argument_types)
        .each_with_object(
          procedure_specialization.super_binding.spawn
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
        build_body_super_binding(procedure_specialization)
      ) do
        buffer_builder = BufferBuilder.new
        procedure_specialization.workspace.with_current_bytecode_builder(
          buffer_builder
        ) do
          procedure_specialization.body.build_bytecode!(procedure_specialization.body_typing)
          Workspace.current_workspace.current_bytecode_builder << Opcodes::RETURN
        end
      end
      Instance.new(buffer_builder)
    end
  end
end
