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

  namespace :hets do
    desc 'Import the hets library.'
    task :lib => :environment do
      user = User.find_all_by_admin(true).first
      user = User.find_by_email! ENV['EMAIL'] unless ENV['EMAIL'].nil?
      Hets.import_ontologies(user, Hets.library_path)
    end
  end

  desc 'Import logic graph.'
  task :logicgraph => :environment do
    def save(entity)
      entity.user = @user if entity.has_attribute? "user_id"
      begin
        entity.save!
      rescue ActiveRecord::RecordInvalid => e
        puts "Validation-Error: #{e.record} (#{e.message})"
      end
    end

    @user = User.find_all_by_admin(true).first
    @user = User.find_by_email! ENV['EMAIL'] unless ENV['EMAIL'].nil?

    LogicgraphParser.parse File.open("#{Rails.root}/registry/LogicGraph.xml"),
      logic:          Proc.new{ |h| save(h) },
      language:       Proc.new{ |h| save(h) },
      logic_mapping:  Proc.new{ |h| save(h) },
      support:        Proc.new{ |h| save(h) }
  end
end
