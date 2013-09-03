### Create ontology types

# create up to n unique names and return no. of results
def unique_names(n)
  @names= []
  n.times do |x|
    @names << Faker::Lorem.word
  end
  @names.uniq!
  @names.length
end

unique_names(10).times do |n|
  OntologyType.create! \
    name:           @names.slice!(-1),
    description:    Faker::Lorem.sentence,
    documentation:  Faker::Internet.url
end

Ontology.all.each do |o|
  o.ontology_type_id = rand(OntologyType.count)+1
  o.save!
end
