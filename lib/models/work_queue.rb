class WorkQueue
  delegate :<<, :any?, to: :jobs

  def pump!
    first_job = jobs.shift
    first_job.work!
  end

  def jobs
    @jobs ||= []
  end
end
