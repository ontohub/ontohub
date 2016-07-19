class OntologyParsingWorker < BaseWorker
  MAX_CONCURRENT_TRIES = 3

  sidekiq_options queue: 'hets'
  # We cannot use Sidekiq's retry feature here because we need to retry per
  # OntologyVersion in the queue of OntologyVersions
  sidekiq_options retry: false

  # queue is an array of triples like
  # [ontology_version_id,
  #  {fast_parse: true/false, files_to_parse_afterwards: array of strings},
  #  try_count]
  # where try_count is the number of the next evaluation attempt
  def perform(version_with_options_queue)
    return if version_with_options_queue.empty?
    initialize_data(version_with_options_queue)

    timeout_job_id = ::TimeoutWorker.start_timeout_clock(@version_id)
    parse_version
  rescue Hets::ConcurrentEvaluator::AlreadyEvaluatingError
    @concurrency_issue_handled = handle_concurrency_issue
  rescue HetsInstance::NoSelectableHetsInstanceError => e
    raise Sidekiq::Retries::Retry.new(e)
  ensure
    Sidekiq::Status.unschedule(timeout_job_id) if timeout_job_id
    if @version_with_options_queue.tail.any? && !@concurrency_issue_handled
      self.class.perform_async(@version_with_options_queue.tail)
    end
  end

  protected

  def initialize_data(version_with_options_queue)
    @version_with_options_queue = version_with_options_queue

    @version_id, @options, @try_count = @version_with_options_queue.head
    @try_count ||= 1
    @concurrency_issue_handled = false
  end

  def parse_version
    # We need to wait a second for the SQL query to finish.
    # Otherwise there is no OntologyVersion with id=@version_id.
    # FIXME This needs to be handled properly.
    sleep 0.1 unless defined?(Sidekiq::Testing) && Sidekiq::Testing.inline?
    version = OntologyVersion.find(@version_id)
    @options.each do |method_name, value|
      version.send(:"#{method_name}=", value)
    end
    version.parse
  end

  def handle_concurrency_issue
    # At this point, it was already tried, hence we include equality
    if @try_count >= MAX_CONCURRENT_TRIES
      SequentialOntologyParsingWorker.perform_async(@version_id, @options)
    else
      self.class.perform_async(rotate_queue_and_increment_try_count)
    end
    true
  end

  def rotate_queue_and_increment_try_count
    version_with_next_options = [@version_id, @options, @try_count + 1]
    [*@version_with_options_queue.tail, version_with_next_options]
  end
end
