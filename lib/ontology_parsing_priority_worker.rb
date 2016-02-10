class OntologyParsingPriorityWorker < OntologyParsingWorker
  sidekiq_options queue: 'priority_push'
end
