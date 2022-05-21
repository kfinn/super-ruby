module AstNodes
  class ProcedureDefinition
    include BaseAstNode

    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.size == 3 &&
        s_expression.first.atom? &&
        s_expression.first.text == 'procedure' &&
        ArgumentListDefinition.match?(s_expression.second)
      )
    end

    def spawn_type_inference
      Jobs::ImmediateTypeInference.new(
        Types::AbstractProcedure.new(
          argument_list_definition.map(&:name),
          body_s_expression
        )
      )
    end

    def build_bytecode!(type_inference)
      Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_bytecode_builder << type_inference.type
    end

    def argument_list_definition
      @argument_list_definition ||= ArgumentListDefinition.new(s_expression.second)
    end

    def body_s_expression
      @body_s_expression ||= s_expression.third
    end
  end
end
