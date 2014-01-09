# Remove existing repositories
FileUtils.rm_rf Ontohub::Application.config.git_root

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
  casl/test1.casl
  casl/test2.casl
  clif/cat.clif
  owl/generations.owl
  owl/pizza.owl
]
ontologies.each do |path|
  path = File.join(Rails.root, 'test', 'fixtures', 'ontologies', path)
  basename = File.basename(path)

  version = repository.save_file path, basename, "#{basename} added", @user
  if version
    version.ontology.update_attribute :description, Faker::Lorem.paragraph
  end
end
