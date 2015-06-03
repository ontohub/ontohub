require 'elasticsearch/rails/tasks/import'
require 'elasticsearch/extensions/test/cluster/tasks'

namespace :elasticsearch do
  desc 'Wipe the Ontology Index from ElasticSearch'
  task :wipe => [:environment] do
    Ontology.__elasticsearch__.delete_index!
  end

  task :start_cluster do
    ENV['TEST_CLUSTER_NODES'] ||= '1'
    env_timeout = ENV['TEST_CLUSTER_TIMEOUT']
    timeout = env_timeout &&  !env_timeout.empty? ? env_timeout.to_i : 120
    Elasticsearch::Extensions::Test::Cluster.start timeout: timeout
  end
end
