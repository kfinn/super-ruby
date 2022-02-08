class WorkQueue
  delegate :any?, to: :jobs_list

  def pump!
    job = jobs_list.shift
    jobs_set.delete(job)
    job.work!
    if job.incomplete?
      job.enqueue!
      deadlocked_jobs << job
      raise "deadlock detected: #{jobs_set.map(&:to_s).join(", ")}" if deadlocked_jobs == jobs_set
    else
      deadlocked_jobs.clear
    end
  end

  def jobs_list
    @jobs_list ||= []
  end

  def jobs_set
    @jobs_set ||= Set.new
  end

  def <<(job)
    return if job.in? jobs_set
    jobs_list << job
    jobs_set << job
  end

  def deadlocked_jobs
    @deadlocked_jobs ||= Set.new
  end
end
