module Jobs
  class SequenceTypeInference
    prepend BaseJob

    def initialize(ast_node)
      @ast_node = ast_node
    end
    attr_reader :ast_node
    attr_accessor :child_type_inferences
    delegate :child_ast_nodes, to: :ast_node

    def complete?
      child_type_inferences&.all?(&:complete?)
    end

    def type_check
      @type_check = SequenceTypeCheck.new(child_type_inferences)
    end

    def work!
      if child_type_inferences.nil?
        self.child_type_inferences =
          Workspace.with_current_super_binding(children_super_binding) do
              child_ast_nodes.map do |child_ast_node|
                Workspace.type_inference_for(child_ast_node)
              end
            end
        child_type_inferences.each { |child_type_inference| child_type_inference.add_downstream self }
      end
    end

    def type
      child_type_inferences.last.type
    end

    def to_s
      "(sequence (#{child_type_inferences&.map(&:to_s)&.join(" ")}))"
    end

    def children_super_binding
      @children_super_binding ||= super_binding.spawn(inherit_dynamic_locals: true)
    end
  end
end
