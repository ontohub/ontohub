require 'sidekiq/worker'

# Worker for Sidekiq
class Worker
  include Sidekiq::Worker

  def perform(*args)
    @try_count, @args = args.head, args.tail
    execute_perform(*args)
  end

  def execute_perform(try_count, type, clazz, method, *args)
    case type
    when 'class'
      clazz.constantize.send method, *args
    when 'record'
      id = args.shift
      clazz.constantize.find(id).send method, *args
    else
      raise ArgumentError, "unsupported type: #{type}"
    end
  rescue ConcurrencyBalancer::AlreadyProcessingError
    handle_concurrency_issue
  end

  def handle_concurrency_issue
    if @try_count >= ConcurrencyBalancer::MAX_TRIES
      SequentialWorker.perform_async(1, *@args)
    else
      self.class.perform_async(@try_count+1, *@args)
    end
  end

  # This method definition is required by sidekiq
  def self.get_sidekiq_options
    {
      'backtrace' => true
    }
  end
  
end

class SequentialWorker < Worker
  sidekiq_options queue: 'sequential'

  def perform(*args)
    @try_count, @args = args.head, args.tail
    ConcurrencyBalancer.sequential_lock do
      execute_perform(*args)
    end
  rescue ConcurrencyBalancer::AlreadyLockedError
    SequentialWorker.perform_async(@try_count+1, *@args)
  end

  def handle_concurrency_issue
    SequentialWorker.perform_async(@try_count+1, *@args)
  end

end
