# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# Create Admin User
User.create!({
  :email    => "admin@example.com",
  :name     => 'admin',
  :admin    => true,
  :password => 'foobar'
}, :as => :admin)

# Create 5 ontologies
5.times do |n|
  o = Ontology.new

  o.uri = "schema://host/ontology/#{n}"
  o.name = Faker::Name.name

  o.import_from_xml File.open('test/fixtures/ontologies/valid.xml')
end
