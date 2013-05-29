namespace :registry do
  desc 'Initially populate logics and languages'
  task :import => :environment do
    user = User.find_all_by_admin(true).first
    user = User.find_by_email! ENV['EMAIL'] unless ENV['EMAIL'].nil?
    store = TripleStore.load "registry/registry.rdf"
    logic_map = Hash.new
    logic_reader = LogicPopulation.new store
    logic_reader.list.each do |logic|
      logic.user = user
      begin
        logic.save!
      rescue ActiveRecord::RecordInvalid => e
        puts "Validation-Error: #{e.record} (#{e.message})"
        next
      end
      logic_map[logic.iri] = logic
    end
    language_reader = LanguagePopulation.new store
    language_reader.list.each do |language|
      language.user = user
      begin
        language.save!
      rescue ActiveRecord::RecordInvalid => e
      puts "Validation-Error: #{e.record} (#{e.message})"
      next
    end
    end
    mapping_reader = LogicMappingPopulation.new store, logic_map
    mapping_reader.list.each do |mapping|
      mapping.user = user
      begin
        mapping.save!
      rescue ActiveRecord::RecordInvalid => e
      puts "Validation-Error: #{e.record} (#{e.message})"
      next
    end
    end
    puts "Imported #{logic_reader.list.count} logics, #{language_reader.list.count} languages and #{mapping_reader.list.count} logic-mappings"
  end
end
