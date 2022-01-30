module Jobs
  module BaseJob
    extend ActiveSupport::Concern

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

    def work!
      super if incomplete?
      downstreams.each(&:enqueue!) if complete?
    end

    def incomplete?
      !complete?
    end

    def has_value?
      false
    end
  end
end
