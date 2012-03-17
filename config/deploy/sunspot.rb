namespace :sunspot do
  desc "Reindex all solr models"
  task :reindex do
    rake_command 'sunspot:reindex'
  end
end
