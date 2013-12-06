FactoryGirl.define do
  factory :category do
    name { Faker::Name.name }
#   association :ontologies, :factory => :single_ontology
  end
end
