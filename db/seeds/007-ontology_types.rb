### Create ontology types

require "#{Rails.root}/db/seed_helper.rb"

count = 10

names_count, names = unique_names(count)

names_count.times do |n|
  OntologyType.create! \
    name:           names.slice!(-1),
    description:    Faker::Lorem.sentence,
    documentation:  Faker::Internet.url
end

Ontology.all.each do |o|
  o.ontology_type_id = rand(OntologyType.count)+1
  o.save!
end
