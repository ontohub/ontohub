class OntologyBatchParseWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(*args)
    @try_count, @args = args.head, args.tail
    execute_perform(*args)
  end

  def execute_perform(try_count, versions)
    done = false

    return if versions.empty?

    version_id, opts = versions.head
    version = OntologyVersion.find(version_id)

    opts.each do |method_name, value|
      version.send(:"#{method_name}=", value)
    end

    version.parse
  rescue ConcurrencyBalancer::AlreadyProcessingError
    done = handle_concurrency_issue
  ensure
    self.class.perform_async(1, versions.tail) unless versions.tail.empty? || done
  end

  def handle_concurrency_issue
    if @try_count >= ConcurrencyBalancer::MAX_TRIES
      SequentialOntologyBatchParseWorker.perform_async(1, *@args)
    else
      self.class.perform_async(@try_count+1, *@args)
    end
    true
  end

end

class SequentialOntologyBatchParseWorker < OntologyBatchParseWorker
  sidekiq_options queue: 'sequential'

  def perform(*args)
    ConcurrencyBalancer.sequential_lock do
      execute_perform(*args)
    end
  end

  def handle_concurrency_issue
    SequentialOntologyBatchParseWorker.perform_async(@try_count+1, *@args)
  end

end
