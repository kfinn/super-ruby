module Jobs
  module BaseJob
    extend ActiveSupport::Concern

    def add_downstream(job)
      if complete?
        job.work!
      else
        downstreams << job
        enqueue!
      end
    end

    def enqueue!
      return if @enqueued
      @eneuqued = true
      Workspace.current_workspace.work_queue << self
    end

    def downstreams
      @downstreams ||= Set.new
    end

    def work!
      super unless complete?
      downstreams.each(&:work!) if complete?
    end

    def incomplete?
      !complete?
    end
  end
end
