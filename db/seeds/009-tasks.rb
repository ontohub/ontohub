### Import Tasks

require "#{Rails.root}/db/seed_helper.rb"

count = 10

names_count, names = unique_names(count)

names_count.times do |n|
  Task.create! \
    name:           names.slice!(-1),
    description:    Faker::Lorem.sentence
end

Ontology.all.each do |o|
  o.task_id= rand(Task.count)+1
  o.save!
end
