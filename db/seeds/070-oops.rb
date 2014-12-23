# Add OOPS! requests and responses to pizza ontology.
ontology = Ontology.where(name: "Pizza").first!
version  = ontology.versions.first
if version
  request  = version.build_request({state: 'done'}, without_protection: true)
  request.save!

  responses = %w(Pitfall Warning Warning Suggestion).map do |type|
    request.responses.create! \
    name:         Faker::Name.name,
    code:         0,
    description:  Faker::Lorem.paragraph,
    element_type: type
  end
end
ontology.symbols.all.select do |symbol|
  symbol.oops_responses = responses.sample(rand(responses.count))
end
