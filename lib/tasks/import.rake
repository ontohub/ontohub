namespace :import do
  namespace :xml_files do
    desc 'Import the latest XML of every ontology again.'
    task :again => :environment do
      ActiveRecord::Base.logger = Logger.new($stdout)
      Ontology.all.map(&:import_latest_version)
    end
  end

  namespace :hets do
    desc 'Import the hets library.'
    task :lib => :environment do
      def find_hets_lib_path
        settings_for_development['paths']['hets']['hets_lib'].
          map { |path| File.expand_path path }.
          find { |path| File.directory?(path) }
      end

      hets_lib_path = ENV['HETS_LIB']
      hets_lib_path ||= find_hets_lib_path
      unless File.directory?(hets_lib_path)
        raise 'No path to hets-lib given or it is not a directory. '\
              'Please specify the path to hets-lib in the environment '\
              'variable HETS_LIB.'
      end

      user   = User.find_by_email! ENV['EMAIL'] unless ENV['EMAIL'].nil?
      user ||= User.find_all_by_admin(true).first

      repo = Repository.new(name: 'Hets lib')

      begin
        repo.save!
      rescue ActiveRecord::RecordInvalid
        abort '"Hets lib" repository already existing.'
      end

      repo.import_ontologies(user, hets_lib_path)
    end
  end

  desc 'Import logic graph.'
  task :logicgraph => :environment do
    RakeHelper.import_logicgraph(ENV['EMAIL'])
  end

  desc 'Import keywords starting with P.'
  task :keywords => :environment do
    ontologySearch = OntologySearch.new()
    puts ontologySearch.makeKeywordListJson('P')
  end

  def settings_for_development
    @settings_for_development ||=
      YAML.load_file(Rails.root.join('config',
                                     'settings_for_development.yml').to_s)
  end
end
