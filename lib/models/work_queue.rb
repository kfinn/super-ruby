class WorkQueue
  delegate :<<, :any?, to: :jobs

  def pump!
    first_job = jobs.shift
    first_job.work!
  end

  def jobs
    @jobs ||= []
  end

  module Job
    extend ActiveSupport::Concern

    def add_downstream(job)
      if complete?
        job.work!
      else
        downstreams << jobs
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
  end
end
