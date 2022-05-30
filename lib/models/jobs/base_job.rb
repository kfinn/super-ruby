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
      workspace.as_current_workspace do
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
      if complete?
        puts "done working #{self}" if ENV['DEBUG']
        downstreams.each(&:enqueue!) if complete?
      end
    rescue StandardError => e
      raise BaseJobFailure.new(self, e)
    end

    def incomplete?
      !complete?
    end

    def to_s
      "(#{self.class.to_s}@#{object_id} #{super})"
    end

    class BaseJobFailure < StandardError
      def initialize(job, cause)
        @job = job
        @cause = cause
        super "BaseJobFailure"
      end
      attr_reader :job, :cause
      delegate :initializing_caller, to: :job

      def message
        <<~TXT
          #  #{job.to_s}
          #  caused by #{cause.message}
          #  #{filtered_cause_backtrace.join("\n#  ")}
          #  initialized by
          #  #  #{filtered_initializing_caller.join("\n#  #  ")}
        TXT
      end

      def filtered_initializing_caller
        @filtered_initializing_caller ||= initializing_caller.reject { |frame| frame.include?('/gems/') || frame.include?('rspec') }
      end

      def filtered_cause_backtrace
        @filtered_cause_backtrace ||= cause.backtrace.reject { |frame| frame.include?('/gems/') || frame.include?('rspec') }
      end
    end
  end
end
