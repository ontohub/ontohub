# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

ActiveRecord::Base.logger = Logger.new($stdout)

# returns up to n unique names
def unique_names(n)
  @names= []
  n.times do |x|
    @names<< Faker::Lorem.word
    @names.uniq!
    @names.length
  end
end

# return files\' capital basename without extension
def basename_no_ext(filename)
  filename.split(".")[0]
end

# Do not create background jobs
OntologyVersion.send :alias_method, :parse_async, :parse
OopsRequest.send :define_method, :async_run, ->{}

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

# initially import logics
Rake::Task['import:logicgraph'].invoke

# Import ontologies
Dir["#{Rails.root}/test/fixtures/ontologies/*/*.{casl,clf,clif,owl}"].each do |file|
  basename = File.basename(file)
  
  clazz = basename.ends_with?('.casl') ? DistributedOntology : SingleOntology
  
  o = clazz.new \
    iri:            "file://db/seeds/#{basename}",
    name:           basename_no_ext(basename).capitalize,
    description:    Faker::Lorem.paragraph,
    documentation:  Faker::Internet.url,
    acronym:        basename_no_ext(basename)[0..2].upcase

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

# Add OOPS! requests and responses to pizza ontology
ontology  = Ontology.where(name: "Pizza").first!
version   = ontology.versions.first
request   = version.build_request({state: 'done'}, without_protection: true)
request.save!

responses = %w( Pitfall Warning Warning Suggestion ).map do |type|
  request.responses.create! \
      name:         Faker::Name.name,
      code:         0,
      description:  Faker::Lorem.paragraph,
      element_type: type
end

ontology.entities.all.select{ |entity| entity.oops_responses = responses.sample(rand(responses.count)) }

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

