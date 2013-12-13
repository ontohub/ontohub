### Import Projects

count = 10

contact = ''
3.times { contact << "#{Faker::Name.name}, " }
contact.chop!.chop!

count.times do
  p = Project.new \
    name:           Faker::Company.catch_phrase,
    institution:    Faker::Company.name,
    homepage:       Faker::Internet.url,
    description:    Faker::Lorem.sentence,
    contact:        contact
  p.save!
end

Ontology.all.each do |o|
  o.projects = Project.where(id: (rand(OntologyType.count)+1))
  o.save!
end
