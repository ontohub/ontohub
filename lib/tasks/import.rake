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
      user = User.find_all_by_admin(true).first
      user = User.find_by_email! ENV['EMAIL'] unless ENV['EMAIL'].nil?
      Hets.import_ontologies(user, Hets.library_path)
    end
  end
end
