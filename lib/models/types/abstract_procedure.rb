module Types
  class AbstractProcedure
    def initialize(argument_names, body)
      @argument_names = argument_names
      @body = body
      @workspace = Workspace.current_workspace
      @super_binding = @workspace.current_super_binding
    end
    attr_reader :argument_names, :body, :workspace, :super_binding

    def delivery_strategy_for_message(message)
      if message == 'specialize'
        :static
      else
        :dynamic
      end
    end

    def message_send_result_typing(message, argument_typings)
      case message
      when 'specialize'
        raise "Invalid arguments count: expected #{argument_names.size}, but got #{argument_typings.size}" unless argument_typings.size == argument_names.size

        Jobs::ProcedureSpecialization.new(
          self,
          argument_names.zip(argument_typings).to_h
        )
      else
        raise "invalid message: #{message}"
      end
    end

    def build_message_send_bytecode!(typing)
      case typing.message
      when 'specialize'
        (typing.argument_typings.size + 1).times do
          Workspace.current_workspace.current_bytecode_builder << Opcodes::DISCARD
        end
        
        concrete_procedure = cached_concrete_procedure_for_argument_types(
          typing.result_typing.argument_types_by_name
        )

        Workspace.current_workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_workspace.current_bytecode_builder << concrete_procedure.bytecode_pointer
      end
    end

    def cached_concrete_procedure_for_argument_types(argument_types_by_name)
      cached_concrete_procedures_by_argument_types[argument_types_by_name].tap do |cached|
        puts "reusing cached concrete procedure: #{cached}" if cached && ENV["DEBUG"]
      end
    end

    def define_concrete_procedure(concrete_procedure)
      if concrete_procedure.argument_types_by_name.in? cached_concrete_procedures_by_argument_types
        raise "duplicate concrete procedure for #{self}: (#{concrete_procedure.argument_types_by_name.values.map(&:to_s).join(", ")})" 
      end
      cached_concrete_procedures_by_argument_types[concrete_procedure.argument_types_by_name] = concrete_procedure
    end

    def to_s
      "(#{argument_names.size.times.map { "?" }.join(", ")}) -> ?"
    end

    private

    def cached_concrete_procedures_by_argument_types
      @cached_concrete_procedures_by_argument_types ||= {}
    end
  end
end
