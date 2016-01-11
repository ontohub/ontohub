class SequentialWorker < Worker
  sidekiq_options queue: 'sequential'

  def perform(*args, try_count: 1)
    establish_arguments(args, try_count: try_count)
    ConcurrencyBalancer.sequential_lock do
      execute_perform(try_count, *args)
    end
  rescue ConcurrencyBalancer::AlreadyLockedError
    handle_concurrency_issue
  end

  def handle_concurrency_issue
    SequentialWorker.perform_async(*@args, try_count: @try_count+1)
  end
end
