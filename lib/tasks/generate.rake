namespace :generate do
  desc 'Import the categories for the ontologies'
  task :categories => :environment do
    Ontology.where("name ilike '%Domain_Fields_Core.owl'").first.create_categories
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
    Settings.formality_levels.each { |t| FormalityLevel.create!(t.to_h) }
    Settings.license_models.each { |t| LicenseModel.create!(t.to_h) }
    Settings.ontology_types.each { |t| OntologyType.create!(t.to_h) }
    Settings.tasks.each { |t| Task.create!(t.to_h) }
  end
end
