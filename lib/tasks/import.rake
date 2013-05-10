namespace :import do
  namespace :xml_files do
    desc 'Import the latest XML of every ontology again.'
    task :again => :environment do
      ActiveRecord::Base.logger = Logger.new($stdout)
      Ontology.all.map(&:import_latest_version)
    end
  end

  namespace :hets do
    def handle_ontology_file(file_name)
      print file_name + "\n"
    end
    task :lib => :environment do
      Hets.traverse(method(:handle_ontology_file))
    end
  end
end
