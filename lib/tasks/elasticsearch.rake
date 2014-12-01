require 'elasticsearch/rails/tasks/import'
require 'elasticsearch/extensions/test/cluster/tasks'

namespace :elasticsearch do
  desc 'Wipe the Ontology Index from ElasticSearch'
  task :wipe => [:environment] do
    Ontology.__elasticsearch__.delete_index!
  end
end