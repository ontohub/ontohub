namespace :import do
  namespace :xml_files do

    desc 'Import the latest XML of every ontology again.'
    task :again => :environment do
      ActiveRecord::Base.logger = Logger.new($stdout)
      Ontology.all.map(&:import_latest_version)
    end

  end
  namespace :logicgraph do
    namespace :from do

      desc 'Import a logic graph from the standard input.'
      task :stdin => :environment do
        Logicgraph.import(nil)
      end

      desc 'Import a logic graph from http transfer directory.'
      task :transfer => :environment do
        Logicgraph.import('tmp/transfer/LogicGraph.rdf')
      end

    end
  end
end
