namespace :import do
  namespace :xml_files do
    desc 'Import the latest XML of every ontology again.'
    task :again => :environment do
      ActiveRecord::Base.logger = Logger.new($stdout)
      Ontology.all.map(&:import_latest_version)
    end
  end

  namespace :hets do
    task :lib => :environment do
      yaml = YAML.load_file(File.join(Rails.root, 'config', 'hets.yml'))
      yaml['hets_lib'].each do |path|
        path = File.expand_path path
        print path + "\n" if File.exists? path
      end
    end
  end
end
