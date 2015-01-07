def update_or_create_by_name(klass, h)
  x = klass.find_by_name(h[:name])
  if x.nil?
    x = klass.create!(h)
  else
    x.update_attributes!(h)
  end
  x
end

def meta_repository
  Repository.where(name: 'meta').
    first_or_create!(description: 'Meta ontologies for Ontohub')
end

def download_from_ontohub_meta(source_file, target_file)
  meta_repository
  user = User.where(admin: true).first
  filepath = "#{Rails.root}/spec/fixtures/ontologies/#{target_file}"
  system("wget -O #{filepath} https://ontohub.org/repositories/meta/master/download/#{source_file}")
  basename = File.basename(filepath)
  version = meta_repository.
    save_file(filepath, basename, "Add #{basename}.", user, do_not_parse: true)
  version.parse
  system("rm #{filepath}")
  version.ontology
end

namespace :generate do
  desc 'Import the categories for the ontologies'
  task :categories => :environment do
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

  desc 'Import the proof statuses for theorems'
  task :proof_statuses => :environment do
    meta_repository
    download_from_ontohub_meta('proof_statuses.owl', 'proof_statuses.owl')
    ProofStatus.refresh_statuses
  end

  desc 'Generate entity trees for ALL OWL ontologies'
  task :owl_ontology_class_hierarchies => :environment do
    #cleaning up
    EntityGroup.destroy_all
    #generating new
    logics = Logic.where(name: ["OWL2", "OWL"])
    ontologies = Ontology.where(logic_id: logics)
    ontologies.each do |ontology|
      begin
        TarjanTree.for(ontology)
      rescue ActiveRecord::RecordNotFound => e
        puts "Could not create entity tree for: #{ontology.name} (#{ontology.id}) caused #{e}"
      end
    end
  end
  
  desc 'Generate entity tree for one specific OWL ontologies'

  task :class_hierachy_for_specific_ontology, [:ontology_id] => :environment do |t,args|
    ontology = Ontology.find!(args.ontology_id)
    #cleaning up to prevent duplicated entity_groups
    ontology.entity_groups.destroy_all
    #generating new
    begin
      TarjanTree.for(ontology)
    rescue ActiveRecord::RecordNotFound => e
      puts "Could not create entity tree for: #{ontology.name} (#{ontology.id}) caused #{e}"
    end
  end

  desc 'Import the values for metadata'
  task :metadata => :environment do
    Settings.formality_levels.each { |t| update_or_create_by_name(FormalityLevel, t.to_h) }
    Settings.license_models.each { |t| update_or_create_by_name(LicenseModel, t.to_h) }
    Settings.ontology_types.each { |t| update_or_create_by_name(OntologyType, t.to_h) }
    Settings.tasks.each { |t| update_or_create_by_name(Task, t.to_h) }
  end
end
