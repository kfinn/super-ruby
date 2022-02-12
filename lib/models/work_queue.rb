class WorkQueue
  delegate :any?, to: :jobs_list

  def pump!
    job = jobs_list.shift
    jobs_set.delete(job)
    job.work!
    if job.incomplete?
      job.enqueue!
      deadlocked_jobs << job
      raise_deadlock! if deadlocked_jobs == jobs_set
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
    puts "enqueueing #{job.to_s}" if ENV['DEBUG']
    jobs_list << job
    jobs_set << job
  end

  def deadlocked_jobs
    @deadlocked_jobs ||= Set.new
  end

  def raise_deadlock!
    binding.irb
    raise "deadlock detected:#{deadlocked_jobs_to_s}" if deadlocked_jobs == jobs_set
  end

  def deadlocked_jobs_to_s
    jobs_set.map { |job| deadlocked_job_to_s(job) }.join
  end

  def deadlocked_job_to_s(deadlocked_job)
    downstreams_s = deadlocked_job.downstreams.empty? ? "" : ", blocking:#{deadlocked_job.downstreams.map { |downstream| "\n\t\t#{downstream.to_s}" }.join}"
    "\n\t#{deadlocked_job.to_s}#{downstreams_s}"
  end
end
