namespace :generate do
  desc 'Import the categories for the ontologies'
  task :categories => :environment do
    RakeHelper::Generate.categories
  end

  desc 'Import the proof statuses for theorems'
  task :proof_statuses => :environment do
    RakeHelper::Generate.proof_statuses
  end

  desc 'Generate symbol trees for ALL OWL ontologies'
  task :owl_ontology_class_hierarchies => :environment do
    RakeHelper::Generate.owl_ontology_class_hierarchies
  end

  desc 'Generate symbol tree for one specific OWL ontologies'
  task :class_hierachy_for_specific_ontology, [:ontology_id] => :environment do |t,args|
    RakeHelper::Generate.owl_ontology_class_hierarchies
  end

  desc 'Import the values for metadata'
  task :metadata => :environment do
    RakeHelper::Generate.metadata
  end
end
