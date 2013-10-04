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
Dir["#{Rails.root}/test/fixtures/ontologies/*/*.{casl,clf,clif,owl}"].each do |file|
  basename = File.basename(file)
  
  version = repository.save_file file, basename, "#{basename} added", @user
  version.ontology.update_attribute :description, Faker::Lorem.paragraph
end
