namespace :registry do
  task :import => :environment do
    user = User.find_by_email! ENV['EMAIL']
    store = TripleStore.load "registry/registry.rdf"
    logic_map = Hash.new
    logic_reader = LogicPopulation.new store
    logic_reader.list.each do |logic|
      logic.user = user
      logic.save!
      logic_map[logic.iri] = logic
    end
    language_reader = LanguagePopulation.new store
    language_reader.list.each do |language|
      language.user = user
      language.save!
    end
    mapping_reader = LogicMappingPopulation.new store, logic_map
    mapping_reader.list.each do |mapping|
      mapping.user = user
      mapping.save!
    end
  end
end
