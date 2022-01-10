class WorkQueue
  delegate :any?, to: :jobs_list

  def pump!
    job = jobs_list.shift
    jobs_set.delete(job)
    job.work!
  end

  def jobs_list
    @jobs_list ||= []
  end

  def jobs_set
    @jobs_set ||= Set.new
  end

  def <<(job)
\   return if job.in? jobs_set
    jobs_list << job
    jobs_set << job
  end
end
