namespace :generate do
  desc 'Import the categories for the ontologies'
  task :categories => :environment do
    Ontology.find_by_name('Domain_model').create_categories
  end
end