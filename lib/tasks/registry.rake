namespace :registry do
  task :import => :environment do
    user = User.find_by_email! ENV['EMAIL']
    store = TripleStore.load "registry/registry.rdf"
    logicReader = LogicPopulation.new store
    logicReader.list.each do |logic|
      logic.user = user
      logic.save!
    end
    langReader = LanguagePopulation.new store
    langReader.list.each do |lang|
      lang.user = user
      lang.save!
    end
  end
end
