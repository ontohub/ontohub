class OntologyParsingWorker < Worker
  sidekiq_options retry: 1, queue: 'hets'

  sidekiq_retry_in do
    1.hour
  end

  # parse_mode can be 'parse_fast' or 'parse_full'
  # *args only holds the array files_to_parse_afterwards
  def perform(ontology_version_id, parse_mode, *args)
    # We need to wait a second for the SQL query to finish.
    # Otherwise there is no OntologyVersion with id=ontology_version_id.
    # FIXME This needs to be handled properly.
    begin
      sleep 1 unless defined?(Sidekiq::Testing) && Sidekiq::Testing.inline?
      super('record', 'OntologyVersion', parse_mode, ontology_version_id, *args,
            try_count: 1)
    rescue HetsInstance::NoSelectableHetsInstanceError => e
      raise e
    rescue Exception => e
      # Dont retry
      raise Sidekiq::Retries::Fail.new(e)
    end
  end
end
