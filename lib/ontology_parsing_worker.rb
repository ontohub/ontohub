class OntologyParsingWorker < Worker
  sidekiq_options retry: 3, queue: 'hets'

  # parse_mode can be 'parse_fast' or 'parse_full'
  # *args only holds the array files_to_parse_afterwards
  def perform(ontology_version_id, parse_mode, *args)
    # We need to wait a second for the SQL query to finish.
    # Otherwise there is no OntologyVersion with id=ontology_version_id.
    # FIXME This needs to be handled properly.
    sleep 1 unless defined?(Sidekiq::Testing) && Sidekiq::Testing.inline?
    super('record', 'OntologyVersion', parse_mode, ontology_version_id, *args,
          try_count: 1)
  end
end
