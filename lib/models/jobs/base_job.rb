module Jobs
  module BaseJob
    extend ActiveSupport::Concern

    def add_downstream(job)
      raise "infinite loop: attempting to add #{job} to #{self}" if job.has_transitive_downstream_job?(self)
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
