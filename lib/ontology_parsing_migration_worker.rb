class OntologyParsingMigrationWorker < OntologyParsingWorker
  sidekiq_options queue: 'hets-migration'
end