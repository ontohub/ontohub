class SequentialOntologyParsingWorker < OntologyParsingWorker
  MUTEX_KEY = "#{self}-evaluating"
  MUTEX_EXPIRATION = HetsInstance::FORCE_FREE_WAITING_PERIOD

  sidekiq_options queue: 'sequential'
  sidekiq_options retry: 10

  def perform(version_id, options)
    initialize_data(version_id, options)
    Semaphore.exclusively(MUTEX_KEY, expiration: MUTEX_EXPIRATION) do
      parse_version
    end
  end

  protected

  def initialize_data(version_id, options)
    @version_id = version_id
    @options = options
  end
end
