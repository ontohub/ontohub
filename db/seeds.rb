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





# Registry ontology
#
#
require 'rdf'
require 'rdf/rdfxml'
require 'rdf/ntriples'

statements = nil
RDF::RDFXML::Reader.open("registry/registry.rdf") do |reader|
  statements = reader.statements.to_a
end && 0

# Map relations
reldir = Hash.new(nil)
relinv = Hash.new(nil)
statements.each do |statement|
  a = "#{statement[0]}"
  b = "#{statement[1]}"
  c = "#{statement[2]}"
  if reldir[b] == nil
    reldir[b] = Hash.new
    relinv[b] = Hash.new
  end
  if reldir[b][a] == nil
    reldir[b][a] = Array.new
  end
  reldir[b][a].push c
  if relinv[b][c] == nil
    relinv[b][c] = Array.new
  end
  relinv[b][c].push a
end

typeIri = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
labelIri = 'http://www.w3.org/2000/01/rdf-schema#label'
commentIri = 'http://www.w3.org/2000/01/rdf-schema#comment'
isDefinedByIri = 'http://www.w3.org/2000/01/rdf-schema#isDefinedBy'
logicTypeIri = 'http://purl.net/dol/1.0/rdf#Logic'
languageTypeIri = 'http://purl.net/dol/1.0/rdf#OntologyLanguage'





# Logic Section
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
# Source: The registry ontology
logicIris = relinv[typeIri][logicTypeIri]
logicIris.each do |logicIri|
  print "\nLOGIC "
  print logicIri
  print "\n"
  logicName = reldir[labelIri][logicIri] != nil ? reldir[labelIri][logicIri][0] : logicIri;
  logicDesc = reldir[commentIri][logicIri] != nil ? reldir[commentIri][logicIri][0] : logicIri;
  logicDefi = reldir[isDefinedByIri][logicIri] != nil ? reldir[isDefinedByIri][logicIri][0] : logicIri;
  logic = Logic.new({
    :iri => logicIri,
    :name => logicName,
    :description => logicDesc,
    :defined_by => logicDefi
  })
  logic.save!
end





# Language Section
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
# Source: The registry ontology
languageIris = relinv[typeIri][languageTypeIri]
languageIris.each do |languageIri|
  print "\nLANGUAGE "
  print languageIri
  print "\n"
  languageName = reldir[labelIri][languageIri] != nil ? reldir[labelIri][languageIri][0] : languageIri;
  languageDesc = reldir[commentIri][languageIri] != nil ? reldir[commentIri][languageIri][0] : "";
  languageDefi = reldir[isDefinedByIri][languageIri] != nil ? reldir[isDefinedByIri][languageIri][0] : "";
  language = Language.new({
    :iri => languageIri,
    :name => languageName,
    :description => languageDesc,
    :defined_by => languageDefi
  })
  language.save!
end





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

