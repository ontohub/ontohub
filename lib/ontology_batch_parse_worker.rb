class OntologyBatchParseWorker < BaseWorker
  sidekiq_options retry: false, queue: 'hets'

  def self.perform_async_with_priority(priority_mode, *args)
    if priority_mode
      perform_async_on_queue('priority_push', 'priority_push', *args)
    else
      perform_async(nil, *args)
    end
  end

  def perform(*args, try_count: 1)
    establish_arguments(args, try_count: try_count)
    @queue = args.shift if args.length == 2
    @args = args
    execute_perform(try_count, args.first)
  end

  def execute_perform(try_count, versions)
    done = false

    return if versions.empty?

    version_id, opts = versions.head
    TimeoutWorker.start_timeout_clock(version_id)

    version = OntologyVersion.find(version_id)

    opts.each do |method_name, value|
      version.send(:"#{method_name}=", value)
    end

    version.parse
  rescue ConcurrencyBalancer::AlreadyProcessingError
    done = handle_concurrency_issue
  ensure
    self.class.perform_async_with_priority(@queue,
      versions.tail, try_count: try_count) unless versions.tail.empty? || done
  end

  def handle_concurrency_issue
    if @try_count >= ConcurrencyBalancer::MAX_TRIES
      SequentialOntologyBatchParseWorker.perform_async(*@args)
    else
      self.class.
        perform_async_with_priority(@queue, *@args, try_count: @try_count + 1)
    end
    true
  end

end

class SequentialOntologyBatchParseWorker < OntologyBatchParseWorker
  sidekiq_options queue: 'sequential'

  def perform(*args, try_count: 1)
    establish_arguments(args, try_count: try_count)
    ConcurrencyBalancer.sequential_lock do
      execute_perform(try_count, args.first)
    end
  rescue ConcurrencyBalancer::AlreadyLockedError
    handle_concurrency_issue
  end

  def handle_concurrency_issue
    SequentialOntologyBatchParseWorker.
      perform_async(*@args, try_count: @try_count + 1)
  end

end
