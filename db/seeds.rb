# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# Create Admin User
user = User.create!({
  :email    => "admin@example.com",
  :name     => 'admin',
  :admin    => true,
  :password => 'foobar'
}, :as => :admin)

# Create Team
team = Team.create! \
  :name       => 'Lorem Ipsum',
  :admin_user => user

# Create some other users
%w(Bob Alice Carol Dave Ted).each_with_index do |name, i|
  user = User.create! \
    :email    => "#{name}@example.com",
    :name     => name,
    :password => 'foobar'
  
  # add two users to the first team
  team.users << user if i < 2
end

# Import ontologies
Dir["#{Rails.root}/db/seeds/*.xml"].each do |file|
  basename = File.basename(file)
  
  o = Ontology.new \
    uri:         "file:///db/seeds/#{basename}",
    name:        basename.split(".")[0].capitalize,
    description: Faker::Lorem.paragraph

  o.import_xml_from_file file
end

# Create 5 ontologies
5.times do |n|
  o = Ontology.new \
    uri:         "gopher://host/ontology/#{n}",
    name:        Faker::Lorem.words(2+rand(4)).join(" "),
    description: Faker::Lorem.paragraph

  o.import_xml_from_file 'test/fixtures/ontologies/valid.xml'
  
  # create a version
  v = o.versions.build
  v.created_at = rand(300).minutes.ago
  v.user       = User.first
  v.save(:validate => false)
end


# Add permissions
Ontology.find_each do |o|
  o.permissions.create! \
    subject: Team.first,
    role: 'owner'
end

Ontology.first.permissions.create! \
  subject: User.first,
  role: 'editor'

