# Add permissions.
Ontology.find_each do |o|
  o.permissions.create! \
    subject: Team.first,
    role:    'owner'
end
