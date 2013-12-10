namespace :generate do
  desc 'Import the categories for the ontologies'
  task :categories => :environment do
    Ontology.find_by_name('Domain_fields_core').create_categories
  end

  desc 'generate the Entitie trees for ALL owl ontologies'
  task :owl_ontology_class_hierarchies => :environment do
    logics = Logic.where(name: ["OWL2", "OWL"])
    ontologies = Ontology.where(logic_id: logics)
    ontologies.each do |ontology|
      puts ontology.name
      ontology.create_entity_tree
    end
  end
end
