module Types
  class AbstractProcedure
    def initialize(argument_names, body)
      @argument_names = argument_names
      @body = body
    end
    attr_reader :argument_names, :body

    def message_send_result_typing(message, argument_types)
      case message
      when 'call'
        raise "invalid arguments count: #{argument_types.map(&:to_s).join(", ")}" unless argument_types.size == argument_names.size
        raise "todo: return a typing that depends on having specialized this procedure"
      else
        raise "invalid message: #{message}"
      end
    end

    def concrete_procedures_by_argument_types
      concrete_procedures_by_argument_types ||= {}
    end

  end
end
