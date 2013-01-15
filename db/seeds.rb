# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

ActiveRecord::Base.logger = Logger.new($stdout)

# Create Admin User
user = User.create!({
  :email    => "admin@example.com",
  :name     => 'admin',
  :admin    => true,
  :password => 'foobar'
}, :as => :admin)

user.confirm!

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

  user.confirm!
  
  # add two users to the first team
  team.users << user if i < 2
end

# Logic Section
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
# Source: The Distributed Otology Language (DOL): use cases, syntax and extensibility
#
# Logics:
# * Common Logic
# * SROIQ
# * DL-RL
# * DL-Lite.g
# * EL++
# * RDFS
# * RDF
logic = Logic.new({
  :name        => "CL",
  :iri         => "http://ontohub.org/cl", 
  :description => "Common logic"
})
logic.save!

logic = Logic.new({
  :name        => "SROIQ",
  :iri         => "http://ontohub.org/sroiq", 
  :description => "SROIQ"
})
logic.save!

logic = Logic.new({
  :name        => "DL-RL",
  :iri         => "http://ontohub.org/dl-rl", 
  :description => "DL-RL is a sublogic of description logic whose reasoning is done by rule-based techlonogies and inspired by Description Logic Programs DLP and pD*."
})
logic.save!

logic = Logic.new({
  :name        => "DL-Lite.g",
  :iri         => "http://ontohub.org/dl-lite.g", 
  :description => "DL-Lite.g"
})
logic.save!

logic = Logic.new({
  :name        => "EL++",
  :iri         => "http://ontohub.org/el++", 
  :description => "DL-EL"
})
logic.save!

logic = Logic.new({
  :name        => "RDFS",
  :iri         => "http://ontohub.org/rdfs", 
  :description => "RDFS"
})
logic.save!

logic = Logic.new({
  :name        => "RDF",
  :iri         => "http://ontohub.org/rdf", 
  :description => "RDF"
})
logic.save!

# Import ontologies
Dir["#{Rails.root}/test/fixtures/ontologies/*/*.{casl,clf,clif,owl}"].each do |file|
  basename = File.basename(file)
  
  clazz = basename.ends_with?('.casl') ? DistributedOntology : SingleOntology
  
  o = clazz.new \
    iri:         "file://db/seeds/#{basename}",
    name:        basename.split(".")[0].capitalize,
    description: Faker::Lorem.paragraph

  v = o.versions.build raw_file: File.open(file)
  v.user       = user
  v.created_at = rand(60).minutes.ago
  v.number     = 1
  
  o.save! 
  o.ontology_version = v;
  o.save!
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

# Add comments
5.times do |n|
  c = Ontology.first.comments.build \
    text: (1 + rand(4)).times.map{ Faker::Lorem.paragraph(5+rand(10)) }.join("\n\n")
  c.user = User.first
  c.created_at = (60 - n*5).minutes.ago
  c.save!
end

