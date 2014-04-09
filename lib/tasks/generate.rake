def update_or_create_by_name(klass, h)
  x = klass.find_by_name(h[:name])
  if x.nil?
    x = klass.create!(h)
  else
    x.update_attributes!(h)
  end
  x
end

namespace :generate do
  desc 'Import the categories for the ontologies'
  task :categories => :environment do
    Ontology.where("name ilike '%Domain Fields Core'").first.create_categories
  end

  desc 'Generate entity trees for ALL OWL ontologies'
  task :owl_ontology_class_hierarchies => :environment do
    logics = Logic.where(name: ["OWL2", "OWL"])
    ontologies = Ontology.where(logic_id: logics)
    ontologies.each do |ontology|
      begin
        ontology.create_entity_tree
      rescue StandardError => e
        puts "Could not create entity tree for: #{ontology.name} (#{ontology.id})"
      end
    end
  end

  desc 'Import the values for metadata'
  task :metadata => :environment do
    Settings.formality_levels.each { |t| update_or_create_by_name(FormalityLevel, t.to_h) }
    Settings.license_models.each { |t| update_or_create_by_name(LicenseModel, t.to_h) }
    Settings.ontology_types.each { |t| update_or_create_by_name(OntologyType, t.to_h) }
    Settings.tasks.each { |t| update_or_create_by_name(Task, t.to_h) }
  end

  desc 'Generate all currently supported ontology file extensions'
  task :ontology_file_extensions => :environment do
    FILE_EXTENSIONS_DISTRIBUTED = %w[casl dol hascasl het]
    FILE_EXTENSIONS_SINGLE = %w[owl obo hs exp maude elf hol isa thy prf omdoc hpf clf clif xml fcstd rdf xmi qvt tptp gen_trm baf]

    FILE_EXTENSIONS_DISTRIBUTED.map! { |e| ".#{e}" }
    FILE_EXTENSIONS_SINGLE.map! { |e| ".#{e}" }

    FILE_EXTENSIONS_DISTRIBUTED.each do |ext|
      ActiveRecord::Base.connection.execute(
        "INSERT INTO ontology_file_extensions (extension, distributed) VALUES ('#{ext}', 'true')")
    end
    FILE_EXTENSIONS_SINGLE.each do |ext|
      ActiveRecord::Base.connection.execute(
        "INSERT INTO ontology_file_extensions (extension, distributed) VALUES ('#{ext}', 'false')")
    end
  end
end
