module RakeHelper
  module LogicGraph
    def self.import(email = nil)
      user = User.find_all_by_admin(true).first
      user = User.find_by_email! email unless email.nil?

      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          system("#{Settings.hets.executable_path} -G")
          LogicgraphParser.parse(File.open(File.join(dir, 'LogicGraph.xml')),
                                 logic:          Proc.new{ |h| save(user, h) },
                                 language:       Proc.new{ |h| save(user, h) },
                                 logic_mapping:  Proc.new{ |h| save(user, h) },
                                 support:        Proc.new{ |h| save(user, h) })
        end
      end
    end

    protected

    def self.save(user, symbol)
      symbol.user = user if symbol.has_attribute? "user_id"
      begin
        symbol.save!
      rescue ActiveRecord::RecordInvalid => e
        puts "Validation-Error: #{e.record} (#{e.message})"
      end
    end
  end

  module Generate
    def self.categories
      ontology = meta_repository.ontologies.
        where("name ilike '%Domain Fields Core'").first
      if ontology
        ontology.create_categories
      else
        ontology = download_from_ontohub_meta(
          'Domain_Fields_Core.owl', 'categories.owl')
      end
      ontology.create_categories
    end

    def self.proof_statuses
      meta_repository
      download_from_ontohub_meta('proof_statuses.owl', 'proof_statuses.owl')
      ProofStatus.refresh_statuses
    end

    def self.owl_ontology_class_hierarchies
      # clean up
      SymbolGroup.destroy_all
      # generating new
      logics = Logic.where(name: ["OWL2", "OWL"])
      ontologies = Ontology.where(logic_id: logics)
      ontologies.each do |ontology|
        begin
          TarjanTree.for(ontology)
        rescue ActiveRecord::RecordNotFound => e
          puts "Could not create symbol tree for: #{ontology.name} (#{ontology.id}) caused #{e}"
        end
      end
    end

    def self.class_hierachy_for_specific_ontology
      ontology = Ontology.find!(args.ontology_id)
      #cleaning up to prevent duplicated symbol_groups
      ontology.symbol_groups.destroy_all
      #generating new
      begin
        TarjanTree.for(ontology)
      rescue ActiveRecord::RecordNotFound => e
        puts "Could not create entity tree for: #{ontology.name} (#{ontology.id}) caused #{e}"
      end
    end

    def self.metadata
      Settings.formality_levels.each { |t| update_or_create_by_name(FormalityLevel, t.to_h) }
      Settings.license_models.each { |t| update_or_create_by_name(LicenseModel, t.to_h) }
      Settings.ontology_types.each { |t| update_or_create_by_name(OntologyType, t.to_h) }
      Settings.tasks.each { |t| update_or_create_by_name(Task, t.to_h) }
    end

    protected

    def self.update_or_create_by_name(klass, h)
      x = klass.find_by_name(h[:name])
      if x.nil?
        x = klass.create!(h)
      else
        x.update_attributes!(h)
      end
      x
    end

    def self.meta_repository
      Repository.where(name: 'meta').
        first_or_create!(description: 'Meta ontologies for Ontohub')
    end

    def self.download_from_ontohub_meta(source_file, target_file)
      meta_repository
      user = User.where(admin: true).first
      filepath = "#{Rails.root}/spec/fixtures/seeds/#{target_file}"
      basename = File.basename(filepath)
      if ENV['DOWNLOAD_FIXTURES']
        source_url =
          "https://ontohub.org/repositories/meta/master/download/#{source_file}"
        temp_file = Tempfile.new([target_file, File.extname(target_file)]).path
        if system("wget -O #{temp_file} #{source_url}")
          filepath = temp_file
        else
          puts 'No connection to ontohub.org. Using local file for the current task.'
        end
      end
      version = meta_repository.
        save_file(filepath, basename, "Add #{basename}.", user, do_parse: false)
      version.parse
      version.ontology
    end
  end

  module Hets
    def self.recreate_instances
      HetsInstance.all.each(&:destroy)
      create_instances
    end

    def self.create_instances
      Settings.hets.instance_urls.each do |hets_url|
        uri = URI(hets_url)
        name = uri.host
        name += ":#{uri.port}" if uri.port
        HetsInstance.create(name: name, uri: uri.to_s, state: 'free', queue_size: 0)
      end
    end
  end
end
