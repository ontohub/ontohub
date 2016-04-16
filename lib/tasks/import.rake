namespace :import do
  namespace :xml_files do
    desc 'Import the latest XML of every ontology again.'
    task :again => :environment do
      ActiveRecord::Base.logger = Logger.new($stdout)
      Ontology.all.map(&:import_latest_version)
    end
  end

  desc 'Import logic graph.'
  task :logicgraph => :environment do
    RakeHelper::LogicGraph.import(ENV['EMAIL'])
  end

  desc 'Import keywords starting with P.'
  task :keywords => :environment do
    ontologySearch = OntologySearch.new()
    puts ontologySearch.makeKeywordListJson('P')
  end
end
