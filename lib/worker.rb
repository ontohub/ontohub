require 'sidekiq/worker'

# Worker for Sidekiq
class Worker < BaseWorker

  # Because of the JSON-Parsing the hash which contains
  # the try_count will contain the try_count key
  # as a string and not as a symbol (which is necessary
  # for the keyword-style to work).
  def perform(*args, try_count: 1)
    establish_arguments(args, try_count: try_count)
    execute_perform(try_count, *args)
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
      SequentialWorker.perform_async(*@args)
    else
      self.class.perform_async(*@args, try_count: @try_count+1)
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
