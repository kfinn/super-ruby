module Jobs
  module BaseJob
    extend ActiveSupport::Concern

    def initialize(*args, **kwargs)
      @workspace = Workspace.current_workspace
      @super_binding = Workspace.current_super_binding
      @initializing_caller = caller.dup
      super
    end

    attr_reader :workspace, :super_binding, :initializing_caller

    def add_downstream(job)
      if complete?
        job.enqueue!
      else
        downstreams << job
        enqueue!
      end
    end

    def enqueue!
      Workspace.work_queue << self
    end

    def downstreams
      @downstreams ||= Set.new
    end

    def has_transitive_downstream_job?(job)
      job.in?(downstreams) || downstreams.any? { |downstream| downstream.has_transitive_downstream_job? job }
    end

    def in_context
      Workspace.with_current_workspace(workspace) do
        Workspace.with_current_super_binding(super_binding) do
          yield
        end
      end
    end

    def work!
      puts "working #{self}" if ENV['DEBUG']
      if incomplete?
        in_context { super }
      end
      downstreams.each(&:enqueue!) if complete?
    rescue StandardError => e
      raise BaseJobFailure.new(self)
    end

    def incomplete?
      !complete?
    end

    def to_s
      "(#{self.class.to_s}@#{object_id} #{super})"
    end

    class BaseJobFailure < StandardError
      def initialize(job)
        @job = job
        super
      end
      attr_reader :job
      delegate :initializing_caller, to: :job

      def message
        "#{job.to_s} initialized by\n#  #{filtered_initializing_caller.join("\n#  ")}"
      end

      def filtered_initializing_caller
        @filtered_initializing_caller ||= initializing_caller.reject { |frame| frame.include?('/gems/') || frame.include?('rspec') }
      end
    end
  end
end
