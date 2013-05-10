namespace :import do
  namespace :xml_files do
    desc 'Import the latest XML of every ontology again.'
    task :again => :environment do
      ActiveRecord::Base.logger = Logger.new($stdout)
      Ontology.all.map(&:import_latest_version)
    end
  end

  namespace :hets do
    def handle_ontology(file_name)
      print file_name + "\n"
    end
    task :lib => :environment do
      Hets.handle_ontologies(method(:handle_ontology), Hets.library_path)
    end
  end
end
