module Jobs
  class IfTypeInference
    prepend BaseJob

    def initialize(ast_node)
      @ast_node = ast_node
    end
    attr_reader :ast_node
    attr_accessor :condition_type_inference, :then_branch_type_inference, :else_branch_type_inference
    delegate :condition_ast_node, :then_branch_ast_node, :else_branch_ast_node, to: :ast_node

    def complete?
      [condition_type_inference, then_branch_type_inference, else_branch_type_inference].all? { |type_inference| type_inference&.complete? }
    end

    def work!
      if condition_type_inference.nil?
        self.condition_type_inference = Workspace.type_inference_for(condition_ast_node)
        condition_type_inference.add_downstream self
      end

      if then_branch_type_inference.nil?
        self.then_branch_type_inference =
          Workspace
            .with_current_super_binding(
              Workspace
              .current_super_binding
              .spawn(inherit_dynamic_locals: true)
            ) do
              Workspace.type_inference_for(then_branch_ast_node)
            end
        then_branch_type_inference.add_downstream self
      end

      if else_branch_type_inference.nil?
        self.else_branch_type_inference =
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
        else_branch_type_inference.add_downstream self
      end
    end

    def type_check
      @type_check ||= IfTypeCheck.new(
        condition_type_inference,
        then_branch_type_inference, 
        else_branch_type_inference,
      )
    end

    def type
      @type ||= Types::Intersection.from_types(then_branch_type_inference.type, else_branch_type_inference.type)
    end

    def to_s
      "(if #{condition_type_inference.to_s} #{then_branch_type_inference.to_s} #{else_branch_type_inference.to_s})"
    end
  end
end
