module Jobs
  module BaseJob
    extend ActiveSupport::Concern

    def initialize(*args, **kwargs)
      @workspace = Workspace.current_workspace
      @super_binding = @workspace.current_super_binding
      super
    end

    attr_reader :workspace, :super_binding

    def add_downstream(job)
      if complete?
        job.enqueue!
      else
        downstreams << job
        enqueue!
      end
    end

    def enqueue!
      Workspace.current_workspace.work_queue << self
    end

    def downstreams
      @downstreams ||= Set.new
    end

    def has_transitive_downstream_job?(job)
      job.in?(downstreams) || downstreams.any? { |downstream| downstream.has_transitive_downstream_job? job }
    end

    def work!
      puts "working #{self}" if ENV['DEBUG']
      if incomplete?
        Workspace.with_current_workspace(workspace) do
          Workspace.current_workspace.with_current_super_binding(super_binding) do
            super
          end
        end
      end
      downstreams.each(&:enqueue!) if complete?
    end

    def incomplete?
      !complete?
    end

    def to_s
      "(#{self.class.to_s} #{super})"
    end
  end
end
