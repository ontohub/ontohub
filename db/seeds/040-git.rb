# Create a repository
repository = Repository.create! \
  name: 'Default'

# Add permissions
Repository.find_each do |o|
  o.permissions.create! \
    subject: Team.first,
    role: 'owner'
end

Repository.first.permissions.create! \
  subject: User.first,
  role: 'editor'

# Import ontologies
ontologies = %w[
  owl/Domain_Fields_Core.owl
  casl/partial_order.casl
  casl/sentence_and_symbol_with_same_name.casl
  casl/test1.casl
  casl/test2.casl
  clif/cat.clif
  clif/hierarchical_import1.clif
  clif/hierarchical_import2.clif
  owl/generations.owl
  owl/pizza.owl
  prove/Subclass.casl
]
ontologies.each do |path|
  path = File.join(Rails.root, 'spec', 'fixtures', 'ontologies', path)
  basename = File.basename(path)

  version = repository.save_file path, basename, "#{basename} added", @user
  begin
    version.parse
  rescue Hets::SyntaxError
    # Suppress this error in the seeds. We want to have erroneous ontologies in
    # the basic data.
  end
  if version
    version.ontology.update_attribute :description, Faker::Lorem.paragraph
  end
end
