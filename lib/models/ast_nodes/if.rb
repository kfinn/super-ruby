module AstNodes
  class If
    include BaseAstNode

    def self.match?(s_expression)
      (
        s_expression.list? &&
        s_expression.first.atom? &&
        s_expression.first.text == 'if' &&
        s_expression.size.in?(3..4)
      )
    end

    def spawn_type_inference
      condition_type_inference = Workspace.type_inference_for(condition_ast_node)

      then_branch_type_inference =
      Workspace
        .with_current_super_binding(
          Workspace
          .current_super_binding
          .spawn(inherit_dynamic_locals: true)
        ) do
          Workspace.type_inference_for(then_branch_ast_node)
        end

      else_branch_type_inference = 
        if else_branch_ast_node.present?
          Workspace
          .with_current_super_binding(
            Workspace
            .current_super_binding
            .spawn(inherit_dynamic_locals: true)
          ) do
            Workspace.type_inference_for(else_branch_ast_node)
          end
        else
          Jobs::ImmediateTypeInference.new(Types::Void.instance)
        end

      Jobs::IfTypeInference.new(
        condition_type_inference,
        then_branch_type_inference,
        else_branch_type_inference
      )
    end  

    def build_bytecode!(type_inference)
      condition_ast_node.build_bytecode!(type_inference.condition_type_inference)

      result_bytecode_builder = BufferBuilder.new
      then_branch_bytecode_builder = BufferBuilder.new
      else_branch_bytecode_builder = BufferBuilder.new

      Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_bytecode_builder << then_branch_bytecode_builder.pointer
      Workspace.current_bytecode_builder << Opcodes::JUMP_UNLESS_FALSE

      Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
      Workspace.current_bytecode_builder << else_branch_bytecode_builder.pointer
      Workspace.current_bytecode_builder << Opcodes::JUMP

      Workspace.with_current_bytecode_builder(then_branch_bytecode_builder) do
        then_branch_ast_node.build_bytecode!(type_inference.then_branch_type_inference)
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << result_bytecode_builder.pointer
        Workspace.current_bytecode_builder << Opcodes::JUMP
      end

      Workspace.with_current_bytecode_builder(else_branch_bytecode_builder) do
        if else_branch_ast_node.present?
          else_branch_ast_node.build_bytecode!(type_inference.else_branch_type_inference) 
        else
          Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
          Workspace.current_bytecode_builder << Types::Void.instance.instance
        end
          
        Workspace.current_bytecode_builder << Opcodes::LOAD_CONSTANT
        Workspace.current_bytecode_builder << result_bytecode_builder.pointer
        Workspace.current_bytecode_builder << Opcodes::JUMP
      end

      Workspace.current_bytecode_builder = result_bytecode_builder
    end

    def condition_ast_node
      @condition_ast_node ||= AstNode.from_s_expression(s_expression.second)
    end

    def then_branch_ast_node
      @then_branch_ast_node ||= AstNode.from_s_expression(s_expression.third)
    end

    def else_branch_ast_node
      unless instance_variable_defined?(:@else_branch_ast_node)
        @else_branch_ast_node = 
          if s_expression.size == 4
            AstNode.from_s_expression(s_expression.fourth)
          end
      end
      @else_branch_ast_node
    end
  end
end
