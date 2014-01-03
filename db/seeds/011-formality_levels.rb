### Import Formality Levels

require "#{Rails.root}/db/seed_helper.rb"

count = 10

names_count, names = unique_names(count)

names_count.times do |n|
  FormalityLevel.create! \
    name:           names.slice!(-1),
    description:    Faker::Lorem.sentence
end

Ontology.all.each do |o|
  (1+rand(3)).times do
    o.formality_levels << FormalityLevel.find(rand(FormalityLevel.count)+1)
  end
  o.save!
end
